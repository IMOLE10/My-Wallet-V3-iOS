// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct CandidateOrderDetails {
    
    /// The payment method
    public let paymentMethod: PaymentMethodType?
    
    /// Fiat value
    public let fiatValue: FiatValue
    
    /// Crypto value
    public let cryptoValue: CryptoValue

    /// The Crypto Currency that is being traded
    public let cryptoCurrency: CryptoCurrency

    /// The Fiat Currency that is being traded
    /// This may be different from the fiat currency used to input the desired amount.
    public let fiatCurrency: FiatCurrency
    
    /// Whether the order is a `Buy` or a `Sell`
    public let action: Order.Action
    
    public let paymentMethodId: String?
    
    private init(paymentMethod: PaymentMethodType?,
                 action: Order.Action,
                 fiatValue: FiatValue,
                 fiatCurrency: FiatCurrency,
                 cryptoValue: CryptoValue,
                 cryptoCurrency: CryptoCurrency,
                 paymentMethodId: String?) {
        self.action = action
        self.paymentMethod = paymentMethod
        self.fiatValue = fiatValue
        self.fiatCurrency = fiatCurrency
        self.cryptoValue = cryptoValue
        self.cryptoCurrency = cryptoCurrency
        self.paymentMethodId = paymentMethodId
    }
    
    public static func buy(paymentMethod: PaymentMethodType? = nil,
                           fiatValue: FiatValue,
                           cryptoValue: CryptoValue,
                           paymentMethodId: String? = nil) -> CandidateOrderDetails {
        CandidateOrderDetails(
            paymentMethod: paymentMethod,
            action: .buy,
            fiatValue: fiatValue,
            fiatCurrency: fiatValue.currencyType,
            cryptoValue: cryptoValue,
            cryptoCurrency: cryptoValue.currencyType,
            paymentMethodId: paymentMethodId
        )
    }
    
    public static func sell(paymentMethod: PaymentMethodType? = nil,
                            fiatValue: FiatValue,
                            destinationFiatCurrency: FiatCurrency,
                            cryptoValue: CryptoValue,
                            paymentMethodId: String? = nil) -> CandidateOrderDetails {
        CandidateOrderDetails(
            paymentMethod: paymentMethod,
            action: .sell,
            fiatValue: fiatValue,
            fiatCurrency: destinationFiatCurrency,
            cryptoValue: cryptoValue,
            cryptoCurrency: cryptoValue.currencyType,
            paymentMethodId: paymentMethodId
        )
    }
}

public struct CheckoutData {
        
    public let order: OrderDetails
    public let paymentAccount: PaymentAccount!
    public let isPaymentMethodFinalized: Bool
    public let linkedBankData: LinkedBankData?
    
    // MARK: - Properties

    public var hasCardCheckoutMade: Bool {
        order.is3DSConfirmedCardOrder || order.isPending3DSCardOrder
    }

    public var isPendingDepositBankWire: Bool {
        order.isPendingDepositBankWire
    }

    public var isPendingDeposit: Bool {
        order.isPendingDeposit
    }
    
    public var isPending3DS: Bool {
        order.isPending3DSCardOrder
    }
        
    public var outputCurrency: CurrencyType {
        order.outputValue.currencyType
    }
    
    public var inputCurrency: CurrencyType {
        order.inputValue.currencyType
    }
    
    public var fiatValue: FiatValue? {
        if let fiat = order.inputValue.fiatValue {
            return fiat
        }
        if let fiat = order.outputValue.fiatValue {
            return fiat
        }
        return nil
    }
    
    public var cryptoValue: CryptoValue? {
        if let crypto = order.inputValue.cryptoValue {
            return crypto
        }
        if let crypto = order.outputValue.cryptoValue {
            return crypto
        }
        return nil
    }
    
    /// `true` if the order is card but is undetermined
    public var isUnknownCardType: Bool {
        order.paymentMethod.isCard && order.paymentMethodId == nil
    }

    /// `true` if the order is bank transfer but is undetermined
    public var isUnknownBankTransfer: Bool {
        order.paymentMethod.isBankTransfer && order.paymentMethodId == nil
    }
    
    public var isPendingConfirmationFunds: Bool {
        order.isPendingConfirmation && order.paymentMethod.isFunds
    }
                
    public init(order: OrderDetails, paymentAccount: PaymentAccount? = nil, linkedBankData: LinkedBankData? = nil) {
        self.order = order
        self.paymentAccount = paymentAccount
        self.linkedBankData = linkedBankData
        isPaymentMethodFinalized = (paymentAccount != nil || order.paymentMethodId != nil)
    }

    public func checkoutData(byAppending cardData: CardData) -> CheckoutData {
        var order = self.order
        order.paymentMethodId = cardData.identifier
        return CheckoutData(order: order)
    }

    public func checkoutData(byAppending bankAccount: LinkedBankData) -> CheckoutData {
        var order = self.order
        order.paymentMethodId = bankAccount.identifier
        return CheckoutData(order: order, linkedBankData: bankAccount)
    }
    
    func checkoutData(byAppending paymentAccount: PaymentAccount) -> CheckoutData {
        CheckoutData(
            order: order,
            paymentAccount: paymentAccount
        )
    }
    
    func checkoutData(byAppending orderDetails: OrderDetails) -> CheckoutData {
        CheckoutData(
            order: orderDetails,
            paymentAccount: paymentAccount
        )
    }
}
