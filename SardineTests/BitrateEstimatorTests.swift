import XCTest
@testable import Sardine

final class BitrateEstimatorTests: XCTestCase {
    func testEstimatedSizeForOneMinuteAtHomeworkClearBitrate() {
        let bytes = BitrateEstimator.estimatedSizeBytes(
            duration: 60,
            videoBitrate: 1_500_000,
            audioBitrate: 96_000
        )

        XCTAssertEqual(bytes, 11_970_000)
    }
}

