import Foundation
import Photos

protocol PhotoLibrarySaving {
    func saveVideo(at url: URL) async throws
}

final class PhotoLibrarySaver: PhotoLibrarySaving {
    func saveVideo(at url: URL) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }
}

