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

## Recommended implementation order

1. Generate the Xcode project from `project.yml`.
2. Make the SwiftUI shell compile.
3. Implement `VideoMetadataReader`.
4. Implement the fixed `homeworkClear` compression path.
5. Add save-to-Files.
6. Add save-to-Photos.
7. Add preset selection and custom bitrate.
8. Add Share Extension.
9. Add App Intents / Shortcuts integration.

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

