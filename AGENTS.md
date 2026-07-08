# AGENTS.md

This repository is intended to be continued by AI coding agents.

## Project purpose

Sardine is a local-only iOS video compression app for homework-style videos. Its main priority is readability of text and clear audio, not extreme compression.

## Non-negotiable product constraints

- Process videos locally on device.
- Do not add cloud upload, accounts, analytics, or third-party SDKs without explicit approval.
- Default output must preserve 1080p-class readability for worksheets and textbooks.
- Do not default to 720p.
- Prefer HEVC/H.265.
- Prefer original audio passthrough; fallback to AAC only when needed.
- Keep UI simple enough for parents and children.

## Current implementation state

The main app flow is implemented:

1. Open the checked-in `Sardine.xcodeproj`.
2. Pick a video from Photos.
3. Read video metadata.
4. Compress locally through the AVFoundation pipeline.
5. Save the result to Photos.
6. Share or save the compressed MP4 through the system share sheet.

Recommended next work:

1. Add more real-video regression samples and record before/after readability.
2. Add custom bitrate controls only if the three presets are not enough.
3. Add Share Extension.
4. Add App Intents / Shortcuts integration.

## Quality bar

Before changing compression defaults, test with real homework videos:

- paper text;
- printed English and Chinese;
- handwriting;
- slight hand movement;
- narrated audio.

Record before/after size, output bitrate, time, and readability.

## Important docs

- `docs/technical-design.md`
- `docs/compression-presets.md`
- `docs/test-plan.md`
- `docs/agent-handoff.md`

## Coding guidance

- Prefer Swift concurrency for orchestration.
- Keep AVFoundation code isolated under `Sardine/Media`.
- Keep presets in `Sardine/Domain/CompressionPreset.swift`.
- Keep UI views thin.
- Do not put compression logic directly in SwiftUI views.
- Add unit tests for bitrate estimation, geometry calculations, and preset behavior before expanding UI.
