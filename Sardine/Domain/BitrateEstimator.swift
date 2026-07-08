import Foundation

enum BitrateEstimator {
    static func estimatedSizeBytes(duration: TimeInterval, videoBitrate: Int, audioBitrate: Int) -> Int64 {
        guard duration > 0 else { return 0 }
        let totalBitsPerSecond = Double(videoBitrate + audioBitrate)
        return Int64((totalBitsPerSecond * duration) / 8.0)
    }
}

