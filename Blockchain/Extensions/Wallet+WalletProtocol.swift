// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

// MARK: - AssetAddressSubscribing

extension Wallet: AssetAddressSubscribing {
    func subscribe(to address: String, asset: CryptoCurrency, addressType: AssetAddressType) {
        switch addressType {
        case .swipeToReceive:
            subscribe(toSwipeAddress: address, assetType: asset.legacy)
        case .standard:
            subscribe(toAddress: address, assetType: asset.legacy)
        }
    }
}

// MARK: - WalletProtocol

extension Wallet: WalletProtocol {

    /// Returns true if the BTC wallet is funded
    var isBitcoinWalletFunded: Bool {
        getTotalActiveBalance() > 0
    }
}
