// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Holds the information to create a wallet
public struct WalletCreation: Equatable {
    public let guid: String
    public let sharedKey: String
    public let password: String

    public init(guid: String, sharedKey: String, password: String) {
        self.guid = guid
        self.sharedKey = sharedKey
        self.password = password
    }
}

/// An enum to be used for wallet creation errors
public enum LegacyWalletCreationError: LocalizedError, Equatable {
    case message(String?)
    case unknownError(String?)

    public var errorDescription: String? {
        switch self {
        case .message(let string):
            return string
        case .unknownError(let string):
            return string
        }
    }
}
