@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

#if os(iOS)
final class PrimaryRowTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = VStack(spacing: 0) {
            PrimaryRow_Previews.previews
        }
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(
                    perceptualPrecision: 0.98,
                    layout: .sizeThatFits,
                    traits: UITraitCollection(userInterfaceStyle: .light)
                ),
                .image(
                    perceptualPrecision: 0.98,
                    layout: .sizeThatFits,
                    traits: UITraitCollection(userInterfaceStyle: .dark)
                )
            ]
        )
    }

    func testRightToLeft() {
        let view = VStack(spacing: 0) {
            PrimaryRow_Previews.previews
        }
        .environment(\.layoutDirection, .rightToLeft)
        .fixedSize()

        assertSnapshot(matching: view, as: .image(perceptualPrecision: 0.98))
    }
}
#endif
