import AVFoundation
import Foundation

struct CompressionProgress: Equatable {
    let fractionCompleted: Double
}

protocol VideoCompressing {
    func compress(
        job: CompressionJob,
        progress: @escaping @Sendable (CompressionProgress) -> Void
    ) async throws -> CompressionResult
}

final class CompressionEngine: VideoCompressing {
    func compress(
        job: CompressionJob,
        progress: @escaping @Sendable (CompressionProgress) -> Void
    ) async throws -> CompressionResult {
        progress(CompressionProgress(fractionCompleted: 0))

        // TODO:
        // 1. Create AVURLAsset.
        // 2. Create AVAssetReader with AVAssetReaderVideoCompositionOutput.
        // 3. Create AVAssetWriter with HEVC settings from CompressionPreset.
        // 4. Prefer audio passthrough; fallback to AAC.
        // 5. Write MP4 to job.outputURL.
        // 6. Return CompressionResult.
        throw SardineError.notImplemented
    }
}

