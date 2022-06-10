// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Errors
import FeatureOpenBankingDomain
import FeatureOpenBankingUI
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit

enum TransactionErrorState: Equatable, Error {
    /// The tansaction is valid
    case none
    /// Any other error
    case unknownError
    /// A network error
    case nabuError(NabuError)
    /// The balance of the source account is not sufficient to execute the transaction.
    /// Takes the balance of the transaction's source in the input currency, the desired amount, the source currency and the target currency.
    case insufficientFunds(MoneyValue, MoneyValue, CurrencyType, CurrencyType)
    /// The available balance of the source account is not sufficient to conver fees required to pay for the transaction.
    /// Takes the total fees required for the transaction and the balance for the source account.
    case belowFees(MoneyValue, MoneyValue)
    /// The amount is below the user's minimum limit for the transaction.
    /// Takes the minimum valid amount required to execute the transaction.
    case belowMinimumLimit(MoneyValue)
    /// The amount is over the maximum allowed for this transaction for the specific source.
    /// Takes the maximum limit, the account name, and the desired amount.
    case overMaximumSourceLimit(MoneyValue, String, MoneyValue)
    /// The amount is over the user's maximum limit for the transaction.
    /// Takes the applicable Periodic Limit that has been exceeded, the available limit, and an optional suggested upgrade.
    case overMaximumPersonalLimit(EffectiveLimit, MoneyValue, TransactionValidationState.LimitsUpgrade?)

    // MARK: - Not checked

    case addressIsContract
    case invalidAddress
    case invalidPassword
    case optionInvalid
    case pendingOrdersLimitReached
    case transactionInFlight
    case fatalError(FatalTransactionError)
}

extension TransactionErrorState {

    var label: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }

    var fatalError: FatalTransactionError? {
        switch self {
        case .fatalError(let error):
            return error
        default:
            return nil
        }
    }
}

extension TransactionErrorState {

    func ux(action: AssetAction) -> UX.Error {
        if let error = extract(UX.Error.self, from: self) {
            return error
        } else if let error = extract(Nabu.Error.self, from: self), error.ux.isNotNil {
            return UX.Error(nabu: error)
        } else if let error = extract(NetworkError.self, from: self).map(Nabu.Error.from), error.ux.isNotNil {
            return UX.Error(nabu: error)
        } else if let error = extract(OpenBanking.Error.self, from: self) {
            let ob = BankState.UI.errors[error, default: .defaultError]
            return UX.Error(
                source: error,
                title: ob.info.title,
                message: ob.info.subtitle,
                icon: (ob.info.media.image?.url).map(UX.Icon.init(url:)),
                actions: .default
            )
        } else {
            let error = extract(Nabu.Error.self, from: self).map(UX.Error.init(nabu:))
            return UX.Error(
                source: self,
                title: recoveryWarningTitle(for: action),
                message: recoveryWarningMessage(for: action),
                metadata: error?.metadata ?? [:]
            )
        }
    }

    func analytics(for action: AssetAction) -> ClientEvent? {
        guard self != .none else { return nil }
        let error = ux(action: action)
        let nabu = error.source as? Nabu.Error
        let network = error.source as? NetworkError
        return ClientEvent.clientError(
            error: error.expected ? label.snakeCase().uppercased() : "OOPS_ERROR",
            networkEndpoint: nabu?.request?.url?.path ?? network?.request?.url?.path,
            networkErrorCode: (nabu?.code.rawValue.i ?? network?.response?.statusCode).map(String.init),
            networkErrorDescription: nabu?.description ?? extract(CustomStringConvertible.self, from: self).description,
            networkErrorId: nabu?.id,
            networkErrorType: nabu?.type.rawValue,
            source: nabu.isNotNil ? "NABU" : "CLIENT",
            title: error.title,
            action: action.description.snakeCase().uppercased()
        )
    }
}
