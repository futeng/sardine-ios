import XCTest
@testable import Sardine

final class CompressionPresetTests: XCTestCase {
    func testHomeworkClearMatchesReadableTextDefaults() {
        let preset = CompressionPreset.homeworkClear

        XCTAssertEqual(preset.codec, .hevc)
        XCTAssertEqual(preset.videoBitrate, 1_500_000)
        XCTAssertEqual(preset.fallbackAudioBitrate, 96_000)
        XCTAssertEqual(preset.maxLongSide, 1920)
        XCTAssertEqual(preset.maxFrameRate, 30)
        XCTAssertEqual(preset.audioMode, .passthroughPreferred)
    }

    func testTextPriorityUsesHigherBitrateThanDefault() {
        XCTAssertGreaterThan(
            CompressionPreset.textPriority.videoBitrate,
            CompressionPreset.homeworkClear.videoBitrate
        )
        XCTAssertEqual(CompressionPreset.textPriority.maxLongSide, 1920)
    }

    func testTinyFileStillKeeps1080pClassOutput() {
        XCTAssertEqual(CompressionPreset.tinyFile.maxLongSide, 1920)
        XCTAssertEqual(CompressionPreset.tinyFile.maxFrameRate, 30)
    }
}
