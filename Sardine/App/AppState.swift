import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var selectedPreset: CompressionPreset = .homeworkClear
    @Published var selectedMetadata: VideoMetadata?
    @Published var recentResult: CompressionResult?
    @Published var isCompressing = false
    @Published var progress: Double = 0
    @Published var errorMessage: String?

    let presets = CompressionPreset.defaultPresets

    private let metadataReader: VideoMetadataReading
    private let compressor: VideoCompressing

    init(
        metadataReader: VideoMetadataReading = VideoMetadataReader(),
        compressor: VideoCompressing = CompressionEngine()
    ) {
        self.metadataReader = metadataReader
        self.compressor = compressor
    }

    func compressVideo(at sourceURL: URL) async {
        isCompressing = true
        progress = 0
        errorMessage = nil
        recentResult = nil

        do {
            let metadata = try await metadataReader.readMetadata(from: sourceURL)
            selectedMetadata = metadata

            try TemporaryFileStore.prepareTemporaryDirectory()
            let outputURL = TemporaryFileStore.outputURL(sourceURL: sourceURL)
            let job = CompressionJob(
                sourceURL: sourceURL,
                preset: selectedPreset,
                outputURL: outputURL
            )

            recentResult = try await compressor.compress(job: job) { [self] progress in
                Task { @MainActor in
                    self.progress = progress.fractionCompleted
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isCompressing = false
    }
}
