// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift

final class ActivityItemPresenter: IdentifiableType {

    typealias AccessibilityId = Accessibility.Identifier.Activity

    var identity: AnyHashable {
        viewModel.identity
    }

    let accessibility: Accessibility = .id(AccessibilityId.ActivityCell.view)
    let viewModel: ActivityItemViewModel
    let badgeImageViewModel: BadgeImageViewModel
    let assetBalanceViewPresenter: AssetBalanceViewPresenter
    var titleLabelContent: Driver<LabelContent> {
        titleRelay.asDriver()
    }
    var descriptionLabelContent: Driver<LabelContent> {
        descriptionRelay.asDriver()
    }
    
    private let titleRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let descriptionRelay = BehaviorRelay<LabelContent>(value: .empty)
    
    init(interactor: ActivityItemInteractor) {
        viewModel = ActivityItemViewModel(event: interactor.event)
        badgeImageViewModel = .template(
            with: viewModel.imageName,
            templateColor: viewModel.eventColor,
            backgroundColor: viewModel.backgroundColor,
            accessibilityIdSuffix: AccessibilityId.ActivityCell.badge
        )
        assetBalanceViewPresenter = AssetBalanceViewPresenter(
            alignment: .trailing,
            interactor: interactor.balanceViewInteractor,
            descriptors: viewModel.descriptors
        )
        descriptionRelay.accept(viewModel.descriptionLabelContent)
        titleRelay.accept(viewModel.titleLabelContent)
    }
}
