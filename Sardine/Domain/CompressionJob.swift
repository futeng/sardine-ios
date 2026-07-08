import Foundation

struct CompressionJob: Equatable {
    let sourceURL: URL
    let preset: CompressionPreset
    let outputURL: URL
}

struct CompressionResult: Equatable {
    let sourceURL: URL
    let outputURL: URL
    let originalSize: Int64
    let compressedSize: Int64
    let duration: TimeInterval
    let preset: CompressionPreset

    var compressionRatio: Double {
        guard originalSize > 0 else { return 0 }
        return Double(compressedSize) / Double(originalSize)
    }
}

