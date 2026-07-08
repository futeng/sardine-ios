import Foundation

enum SardineError: LocalizedError, Equatable {
    case notImplemented
    case missingVideoTrack
    case unsupportedVideo
    case cannotCreateReader
    case cannotCreateWriter
    case compressionFailed
    case photoLibrarySaveFailed
    case insufficientStorage

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "This feature has not been implemented yet."
        case .missingVideoTrack:
            return "The selected file does not contain a video track."
        case .unsupportedVideo:
            return "This video format is not supported yet."
        case .cannotCreateReader:
            return "Could not create AVAssetReader for the selected video."
        case .cannotCreateWriter:
            return "Could not create AVAssetWriter for the output file."
        case .compressionFailed:
            return "Video compression failed."
        case .photoLibrarySaveFailed:
            return "Could not save the compressed video to Photos."
        case .insufficientStorage:
            return "There is not enough local storage for the compressed output."
        }
    }
}
