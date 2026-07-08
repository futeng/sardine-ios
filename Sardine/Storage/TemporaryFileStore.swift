import Foundation

enum TemporaryFileStore {
    static func outputURL(sourceURL: URL, extension fileExtension: String = "mp4") -> URL {
        let stem = sourceURL.deletingPathExtension().lastPathComponent
        let filename = "\(stem)-compressed-\(UUID().uuidString).\(fileExtension)"
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("Sardine", isDirectory: true)
            .appendingPathComponent(filename)
    }

    static func prepareTemporaryDirectory() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("Sardine", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}

