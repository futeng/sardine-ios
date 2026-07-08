import AVFoundation
import Foundation

protocol VideoMetadataReading {
    func readMetadata(from url: URL) async throws -> VideoMetadata
}

final class VideoMetadataReader: VideoMetadataReading {
    func readMetadata(from url: URL) async throws -> VideoMetadata {
        let asset = AVURLAsset(url: url)

        let duration = try await asset.load(.duration)
        let tracks = try await asset.load(.tracks)

        guard let videoTrack = tracks.first(where: { $0.mediaType == .video }) else {
            throw SardineError.missingVideoTrack
        }

        let naturalSize = try await videoTrack.load(.naturalSize)
        let preferredTransform = try await videoTrack.load(.preferredTransform)
        let nominalFrameRate = try await videoTrack.load(.nominalFrameRate)
        let displaySize = VideoGeometry.displaySize(naturalSize: naturalSize, preferredTransform: preferredTransform)

        let fileSize = VideoMetadataReader.fileSize(for: url)
        let seconds = CMTimeGetSeconds(duration)
        let estimatedBitrate = seconds > 0 ? Double(fileSize * 8) / seconds : 0

        return VideoMetadata(
            duration: seconds,
            naturalSize: naturalSize,
            displaySize: displaySize,
            frameRate: Double(nominalFrameRate),
            fileSize: fileSize,
            estimatedBitrate: estimatedBitrate,
            hasAudio: tracks.contains(where: { $0.mediaType == .audio }),
            isHDR: false,
            codec: nil
        )
    }

    private static func fileSize(for url: URL) -> Int64 {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        return Int64(values?.fileSize ?? 0)
    }
}

