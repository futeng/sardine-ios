import CoreGraphics
import Foundation

struct VideoMetadata: Equatable {
    let duration: TimeInterval
    let naturalSize: CGSize
    let displaySize: CGSize
    let frameRate: Double
    let fileSize: Int64
    let estimatedBitrate: Double
    let hasAudio: Bool
    let isHDR: Bool
    let codec: String?
}

