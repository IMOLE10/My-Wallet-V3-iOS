// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum TransactionValidationState: Equatable {
    case uninitialized
    case addressIsContract
    case belowMinimumLimit
    case canExecute
    case insufficientFunds
    case insufficientGas
    case invalidAddress
    case invalidAmount
    case insufficientFundsForFees
    case invoiceExpired
    case optionInvalid
    case overGoldTierLimit
    case overMaximumLimit
    case overSilverTierLimit
    case pendingOrdersLimitReached
    case transactionInFlight
    case unknownError
}
