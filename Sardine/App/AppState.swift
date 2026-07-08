import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var selectedPreset: CompressionPreset = .homeworkClear
    @Published var recentResult: CompressionResult?
    @Published var isCompressing = false
    @Published var progress: Double = 0

    let presets = CompressionPreset.defaultPresets
}

