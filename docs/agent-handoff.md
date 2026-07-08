# Agent Handoff

This repo is ready for a follow-up AI agent to implement the iOS app.

## Current state

Done:

- Product naming finalized as `Sardine`.
- Chinese app name: `沙丁鱼`.
- Repo scaffold created.
- Brand avatar generated.
- App icon assets generated.
- Technical design written.
- XcodeGen project spec added.
- SwiftUI source skeleton added.

Not done:

- Xcode project generation has not been run in this repo yet.
- AVFoundation compression pipeline is not implemented.
- Photo library save/export is only planned.
- Share Extension and App Intents are not implemented.

## First commands on the development machine

```bash
cd /path/to/sardine-ios
brew install xcodegen
xcodegen generate
open Sardine.xcodeproj
```

## First implementation target

Implement one path only:

```text
Input video -> metadata read -> HEVC 1080p30 1.5Mbps -> MP4 temp file -> save to Files
```

Do not start with Share Extension or Shortcuts.

## Highest-risk files

- `Sardine/Media/CompressionEngine.swift`
- `Sardine/Media/VideoMetadataReader.swift`
- `Sardine/Media/VideoGeometry.swift`

Keep AVFoundation logic isolated there.

## Product trap to avoid

Do not optimize for the smallest possible file in v1. The correct default is “readable homework text”.

If a future agent wants to reduce default bitrate, require side-by-side screenshot tests with worksheet text.

## Suggested next milestone

M1:

- project builds;
- home screen appears;
- preset list renders;
- metadata reader can inspect a selected local video file;
- no compression yet.

M2:

- one hard-coded compression path works on a real iPhone;
- result can be exported to Files.

M3:

- save to Photos;
- progress UI;
- error handling.

