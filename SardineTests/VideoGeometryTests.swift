import CoreGraphics
import XCTest
@testable import Sardine

final class VideoGeometryTests: XCTestCase {
    func testOutputSizeKeepsEvenDimensions() {
        let size = VideoGeometry.outputSize(
            displaySize: CGSize(width: 1081, height: 1921),
            maxLongSide: 1920
        )

        XCTAssertEqual(size.width.truncatingRemainder(dividingBy: 2), 0)
        XCTAssertEqual(size.height.truncatingRemainder(dividingBy: 2), 0)
        XCTAssertLessThanOrEqual(max(size.width, size.height), 1920)
    }
}

