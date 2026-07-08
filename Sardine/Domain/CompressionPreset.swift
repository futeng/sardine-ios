import Foundation

struct CompressionPreset: Identifiable, Codable, Equatable {
    let id: String
    let displayName: String
    let summary: String
    let videoBitrate: Int
    let fallbackAudioBitrate: Int
    let maxLongSide: Int
    let maxFrameRate: Int
    let codec: VideoCodec
    let audioMode: AudioMode

    static let homeworkClear = CompressionPreset(
        id: "homework-clear",
        displayName: "清晰压缩",
        summary: "默认档位。适合大多数交作业视频。",
        videoBitrate: 1_500_000,
        fallbackAudioBitrate: 96_000,
        maxLongSide: 1920,
        maxFrameRate: 30,
        codec: .hevc,
        audioMode: .passthroughPreferred
    )

    static let textPriority = CompressionPreset(
        id: "text-priority",
        displayName: "文字优先",
        summary: "适合教材、试卷、手写字。体积更大，文字更稳。",
        videoBitrate: 2_000_000,
        fallbackAudioBitrate: 128_000,
        maxLongSide: 1920,
        maxFrameRate: 30,
        codec: .hevc,
        audioMode: .passthroughPreferred
    )

    static let tinyFile = CompressionPreset(
        id: "tiny-file",
        displayName: "更小体积",
        summary: "尽量压小。文字可能变糊，慎用于作业纸。",
        videoBitrate: 1_000_000,
        fallbackAudioBitrate: 96_000,
        maxLongSide: 1920,
        maxFrameRate: 30,
        codec: .hevc,
        audioMode: .aac96k
    )

    static let defaultPresets: [CompressionPreset] = [
        .homeworkClear,
        .textPriority,
        .tinyFile
    ]
}

enum VideoCodec: String, Codable {
    case hevc
    case h264
}

enum AudioMode: String, Codable {
    case passthroughPreferred
    case aac64k
    case aac96k
    case aac128k
}

