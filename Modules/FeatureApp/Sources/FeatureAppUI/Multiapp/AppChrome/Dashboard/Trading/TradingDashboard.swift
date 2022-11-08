// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import FeatureDashboardUI
import Foundation
import SwiftUI

public struct TradingDashboard: ReducerProtocol {
    let app: AppProtocol
    let allCryptoAssetsRepository: AllCryptoAssetsRepositoryAPI
    let allCryptoAssetService: AllCryptoAssetsServiceAPI

    public enum Route: NavigationRoute {
        case showAllAssets

        public func destination(in store: Store<State, Action>) -> some View {
            switch self {

            case .showAllAssets:
                return AllAssetsView(store: store.scope(state: \.allAssetsState, action: Action.allAssetsActions))
            }
        }
    }

    public enum Action: Equatable, NavigationAction {
        case route(RouteIntent<Route>?)
        case allAssetsActions(FeatureAllAssets.Action)
        case assetsAction(DashboardCustodialAssetsSection.Action)
        case activityAction(DashboardActivitySection.Action)
    }

    public struct State: Equatable, NavigationState {
        public var title: String
        public var assetsState: DashboardCustodialAssetsSection.State = .init()
        public var activityState: DashboardActivitySection.State = .init()

        public var allAssetsState: FeatureAllAssets.State = .init()
        public var route: RouteIntent<Route>?

        public init(title: String) {
            self.title = title
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.assetsState, action: /Action.assetsAction) {
            DashboardCustodialAssetsSection(
                allCryptoAssetsRepository: self.allCryptoAssetsRepository,
                allCryptoAssetService: self.allCryptoAssetService,
                app: self.app
            )
        }

        Scope(state: \.activityState, action: /Action.activityAction) {
            DashboardActivitySection(
                app: self.app
            )
        }

        Reduce { state, action in
            switch action {
            case .route(let routeIntent):
                state.route = routeIntent
                return .none
            case .assetsAction(let action):
                switch action {
                case .onAllAssetsTapped:
                    state.route = .navigate(to: .showAllAssets)
                    return .none
                default:
                    return .none
                }
            case .allAssetsActions:
                return .none
            case .activityAction:
                return .none
            }
        }
    }
}
