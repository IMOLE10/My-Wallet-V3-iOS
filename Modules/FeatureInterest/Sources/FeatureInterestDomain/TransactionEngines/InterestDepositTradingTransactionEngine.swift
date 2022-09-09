// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureProductsDomain
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

/// Transaction Engine for Interest Deposit from a Trading Account.
public final class InterestDepositTradingTransactionEngine: InterestTransactionEngine {

    // MARK: - InterestTransactionEngine

    public var minimumDepositLimits: Single<FiatValue> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [sourceCryptoCurrency, accountLimitsRepository] fiatCurrency in
                accountLimitsRepository
                    .fetchInterestAccountLimitsForCryptoCurrency(
                        sourceCryptoCurrency,
                        fiatCurrency: fiatCurrency
                    )
            }
            .map(\.minDepositAmount)
            .asSingle()
    }

    // MARK: - TransactionEngine

    public var askForRefreshConfirmation: AskForRefreshConfirmation!
    public var sourceAccount: BlockchainAccount!
    public var transactionTarget: TransactionTarget!

    // MARK: - InterestTransactionEngine

    public let walletCurrencyService: FiatCurrencyServiceAPI
    public let currencyConversionService: CurrencyConversionServiceAPI
    // Used to check product eligibility
    private let productsService: FeatureProductsDomain.ProductsServiceAPI

    // MARK: - Private Properties

    private var minimumDepositCryptoLimits: Single<CryptoValue> {
        minimumDepositLimits
            .flatMap { [currencyConversionService, sourceAsset] fiatCurrency -> Single<(FiatValue, FiatValue)> in
                let quote = currencyConversionService
                    .conversionRate(from: sourceAsset, to: fiatCurrency.currencyType)
                    .asSingle()
                    .map { $0.fiatValue ?? .zero(currency: fiatCurrency.currency) }
                return Single.zip(quote, .just(fiatCurrency))
            }
            .map { [sourceAsset] (quote: FiatValue, deposit: FiatValue) -> CryptoValue in
                deposit.convert(usingInverse: quote, currency: sourceAsset.cryptoCurrency!)
            }
    }

    private var availableBalance: Single<MoneyValue> {
        sourceAccount
            .balance
            .asSingle()
    }

    private var interestAccountLimits: Single<InterestAccountLimits> {
        walletCurrencyService
            .displayCurrency
            .flatMap { [accountLimitsRepository, sourceAsset] fiatCurrency in
                accountLimitsRepository
                    .fetchInterestAccountLimitsForCryptoCurrency(
                        sourceAsset.cryptoCurrency!,
                        fiatCurrency: fiatCurrency
                    )
            }
            .asSingle()
    }

    private let accountTransferRepository: InterestAccountTransferRepositoryAPI
    private let accountLimitsRepository: InterestAccountLimitsRepositoryAPI

    // MARK: - Init

    init(
        walletCurrencyService: FiatCurrencyServiceAPI = resolve(),
        currencyConversionService: CurrencyConversionServiceAPI = resolve(),
        accountLimitsRepository: InterestAccountLimitsRepositoryAPI = resolve(),
        accountTransferRepository: InterestAccountTransferRepositoryAPI = resolve(),
        productsService: FeatureProductsDomain.ProductsServiceAPI = resolve()
    ) {
        self.walletCurrencyService = walletCurrencyService
        self.currencyConversionService = currencyConversionService
        self.accountTransferRepository = accountTransferRepository
        self.accountLimitsRepository = accountLimitsRepository
        self.productsService = productsService
    }

    public func assertInputsValid() {
        precondition(sourceAccount is TradingAccount)
        precondition(transactionTarget is InterestAccount)
        precondition(transactionTarget is CryptoAccount)
        precondition(sourceAsset == (transactionTarget as! CryptoAccount).asset)
    }

    public func initializeTransaction()
        -> Single<PendingTransaction>
    {
        Single
            .zip(
                minimumDepositCryptoLimits,
                availableBalance,
                walletCurrencyService
                    .displayCurrency
                    .asSingle()
            )
            .map { limits, balance, fiatCurrency -> PendingTransaction in
                let asset = limits.currency
                return PendingTransaction(
                    amount: .zero(currency: asset),
                    available: balance,
                    feeAmount: .zero(currency: asset),
                    feeForFullAvailable: .zero(currency: asset),
                    feeSelection: .init(selectedLevel: .none, availableLevels: [.none]),
                    selectedFiatCurrency: fiatCurrency,
                    limits: .init(
                        currencyType: limits.currencyType,
                        minimum: limits.moneyValue,
                        maximum: nil,
                        maximumDaily: nil,
                        maximumAnnual: nil,
                        effectiveLimit: nil,
                        suggestedUpgrade: nil
                    )
                )
            }
    }

    public func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        availableBalance
            .map { balance in
                pendingTransaction
                    .update(
                        amount: amount,
                        available: balance
                    )
            }
    }

    public func validateAmount(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        availableBalance
            .flatMapCompletable(weak: self) { (self, balance) in
                self.checkIfAvailableBalanceIsSufficient(
                    pendingTransaction,
                    balance: balance
                )
                .andThen(
                    self.checkIfAmountIsBelowMinimumLimit(
                        pendingTransaction
                    )
                )
            }
            .updateTxValidityCompletable(
                pendingTransaction: pendingTransaction
            )
    }

    public func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        guard pendingTransaction.agreementOptionValue, pendingTransaction.termsOptionValue else {
            return .just(pendingTransaction.update(validationState: .optionInvalid))
        }
        return validateAmount(pendingTransaction: pendingTransaction)
    }

    public func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        let source = sourceAccount.label
        let destination = transactionTarget.label
        let termsChecked = getTermsOptionValueFromPendingTransaction(pendingTransaction)
        let agreementChecked = getTransferAgreementOptionValueFromPendingTransaction(pendingTransaction)
        return fiatAmountAndFees(from: pendingTransaction)
            .map { fiatAmount, fiatFees -> PendingTransaction in
                pendingTransaction
                    .update(
                        confirmations: [
                            TransactionConfirmations.Source(value: source),
                            TransactionConfirmations.Destination(value: destination),
                            TransactionConfirmations.FeedTotal(
                                amount: pendingTransaction.amount,
                                amountInFiat: fiatAmount.moneyValue,
                                fee: pendingTransaction.feeAmount,
                                feeInFiat: fiatFees.moneyValue
                            )
                        ]
                    )
            }
            .map { [weak self] pendingTransaction in
                guard let self = self else {
                    unexpectedDeallocation()
                }
                return self.modifyEngineConfirmations(
                    pendingTransaction,
                    termsChecked: termsChecked,
                    agreementChecked: agreementChecked
                )
            }
    }

    public func execute(
        pendingTransaction: PendingTransaction
    ) -> Single<TransactionResult> {
        accountTransferRepository
            .createInterestAccountCustodialTransfer(pendingTransaction.amount)
            .mapError { _ in
                TransactionValidationFailure(state: .unknownError)
            }
            .map { _ in
                TransactionResult.unHashed(amount: pendingTransaction.amount, orderId: nil)
            }
            .asSingle()
    }

    public func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }
}
