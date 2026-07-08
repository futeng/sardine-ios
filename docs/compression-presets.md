# Compression Presets

Sardine is optimized for homework videos. The compression defaults should protect readable text first, then reduce file size.

## Recommended presets

| Preset | Resolution | Frame rate | Video bitrate | Audio | Use case |
|---|---:|---:|---:|---:|---|
| Homework Clear | Long side <= 1920 | <= 30fps | 1.5Mbps | passthrough preferred, AAC 96k fallback | default |
| Text Priority | Long side <= 1920 | <= 30fps | 2.0Mbps | passthrough preferred, AAC 128k fallback | printed text, handwriting, worksheets |
| Tiny File | Long side <= 1920 | <= 30fps | 1.0Mbps | AAC 64k/96k | maximum shrink, quality warning required |
| Compatibility | Long side <= 1920 | <= 30fps | 2.0Mbps | AAC 128k | H.264 fallback for older receivers |

## Why these defaults

The earlier Mac workflow used CPU `x265` with CRF-style quality control. iPhone uses hardware HEVC through AVFoundation / VideoToolbox, which is much faster but less efficient at preserving fine text at very low bitrates.

For iPhone-only compression:

- 1.0Mbps can be too aggressive for worksheets.
- 1.5Mbps is a reasonable default.
- 2.0Mbps is safer for text-heavy clips.
- 720p should not be the default because text edges degrade quickly.
- 60fps should usually be reduced to 30fps for homework videos.

## Size estimation

Approximate formula:

```text
output MB ≈ (video Mbps + audio Mbps) × duration seconds ÷ 8
```

Examples for a 60-second video:

| Video | Audio | Expected size |
|---:|---:|---:|
| 1.0Mbps | 96kbps | ~8.2MB |
| 1.5Mbps | 96kbps | ~12.0MB |
| 2.0Mbps | 128kbps | ~16.0MB |

The app should show this estimate before compression.

## Implementation notes

Use `AVVideoAverageBitRateKey` for the target video bitrate:

```swift
AVVideoCompressionPropertiesKey: [
    AVVideoAverageBitRateKey: preset.videoBitrate,
    AVVideoExpectedSourceFrameRateKey: preset.maxFrameRate,
    AVVideoMaxKeyFrameIntervalKey: preset.maxFrameRate
]
```

This is not CRF. Do not expose it as CRF in UI.

## User-facing wording

Avoid technical labels in the default UI.

Recommended labels:

- `清晰压缩`
- `文字优先`
- `更小体积`
- `自定义`

If `Tiny File` is selected, show:

> 文件会更小，但文字可能变糊。交作业视频建议优先使用“清晰压缩”。

