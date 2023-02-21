// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class LargeSegmentedControlTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = VStack(spacing: Spacing.baseline) {
            LargeSegmentedControl_Previews.previews
        }
        .frame(width: 320)
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(perceptualPrecision: 0.98,
                    layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(perceptualPrecision: 0.98,
                    layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func testRightToLeft() {
        let view = VStack(spacing: Spacing.baseline) {
            LargeSegmentedControl_Previews.previews
        }
        .environment(\.layoutDirection, .rightToLeft)
        .frame(width: 320)
        .fixedSize()

        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.98))
    }
}
#endif
