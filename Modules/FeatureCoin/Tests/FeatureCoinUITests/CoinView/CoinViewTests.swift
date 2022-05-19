// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
@testable import FeatureCoinDomain
@testable import FeatureCoinUI
import SnapshotTesting
import SwiftUI
import XCTest

final class CoinViewTests: XCTestCase {

//    func test_CoinView_goldUser() {
//        try? XCTSkipIf(true)
//        let coinView = PrimaryNavigationView {
//            CoinView(
//                store: .init(
//                    initialState: .init(
//                        currency: .bitcoin,
//                        kycStatus: .gold,
//                        accounts: [
//                            .preview.privateKey,
//                            .preview.trading,
//                            .preview.rewards
//                        ],
//                        assetInformation: .preview,
//                        interestRate: 5,
//                        isFavorite: true,
//                        graph: .init(
//                            interval: .day,
//                            result: .success(.preview)
//                        )
//                    ),
//                    reducer: coinViewReducer,
//                    environment: .preview
//                )
//            )
//            .app(App.preview)
//        }
//        .frame(width: 375, height: 1100)
//
//        assertSnapshot(matching: coinView, as: .image, record: false)
//    }
//
//    func test_CoinView_silverUser() {
//        try? XCTSkipIf(true)
//        let coinView = PrimaryNavigationView {
//            CoinView(
//                store: .init(
//                    initialState: .init(
//                        currency: .ethereum,
//                        kycStatus: .silver,
//                        accounts: [
//                            .preview.privateKey,
//                            .preview.trading,
//                            .preview.rewards
//                        ],
//                        assetInformation: .preview,
//                        interestRate: 7,
//                        isFavorite: false,
//                        graph: .init(
//                            interval: .day,
//                            result: .success(.preview)
//                        )
//                    ),
//                    reducer: coinViewReducer,
//                    environment: .preview
//                )
//            )
//            .app(App.preview)
//        }
//        .frame(width: 375, height: 1100)
//
//        assertSnapshot(matching: coinView, as: .image, record: false)
//    }

//    func test_CoinView_UnverifiedUser() {
//        try? XCTSkipIf(true)
//        let coinView = PrimaryNavigationView {
//            CoinView(
//                store: .init(
//                    initialState: .init(
//                        currency: .bitcoin,
//                        kycStatus: .unverified,
//                        accounts: [
//                            .preview.privateKey
//                        ],
//                        assetInformation: .preview,
//                        isFavorite: false,
//                        graph: .init(
//                            interval: .day,
//                            result: .success(.preview)
//                        )
//                    ),
//                    reducer: coinViewReducer,
//                    environment: .preview
//                )
//            )
//            .app(App.preview)
//        }
//        .frame(width: 375, height: 1100)
//
//        assertSnapshot(matching: coinView, as: .image, record: false)
//    }

    func test_CoinView_Error() {
        let coinView = PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .bitcoin,
                        kycStatus: .unverified,
                        error: .failedToLoad,
                        isFavorite: false,
                        graph: .init(
                            interval: .day,
                            result: .failure(.serverError(.badResponse))
                        )
                    ),
                    reducer: coinViewReducer,
                    environment: .previewEmpty
                )
            )
            .app(App.preview)
        }
        .frame(width: 375, height: 650)

        assertSnapshot(matching: coinView, as: .image, record: false)
    }

    func test_CoinView_Loading() {
        let coinView = PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .stellar,
                        graph: .init(isFetching: true)
                    ),
                    reducer: coinViewReducer,
                    environment: .previewEmpty
                )
            )
            .app(App.preview)
        }
        .frame(width: 375, height: 600)

        assertSnapshot(matching: coinView, as: .image, record: false)
    }

//    func test_CoinView_notTradable() {
//        try? XCTSkipIf(true)
//        let coinView = PrimaryNavigationView {
//            CoinView(
//                store: .init(
//                    initialState: .init(
//                        currency: .nonTradeable,
//                        kycStatus: .unverified,
//                        assetInformation: .preview,
//                        isFavorite: false,
//                        graph: .init(
//                            interval: .day,
//                            result: .success(.preview)
//                        )
//                    ),
//                    reducer: coinViewReducer,
//                    environment: .preview
//                )
//            )
//            .app(App.preview)
//        }
//        .frame(width: 375, height: 900)
//
//        assertSnapshot(matching: coinView, as: .image, record: false)
//    }
}
