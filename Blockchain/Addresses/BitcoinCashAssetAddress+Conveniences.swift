// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit

extension BitcoinCashAssetAddress {
    // TODO: Replace with convenience function in BitcoinKit
    @available(*, deprecated, message: "This should be replaced by a convenience function in BitcoinKit")
    func bitcoinAssetAddress(from wallet: Wallet) -> BitcoinCashAssetAddress? {
        guard let address = wallet.fromBitcoinCash(publicKey) else {
            return nil
        }
        return BitcoinCashAssetAddress(publicKey: address)
    }
}
