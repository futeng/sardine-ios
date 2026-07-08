# Agent Handoff

This repo is ready for a follow-up AI agent to continue the iOS app.

## Current state

Done:

- Product naming finalized as `Sardine`.
- Chinese app name: `沙丁鱼`.
- Brand avatar generated.
- App icon assets generated.
- Technical design written.
- Checked-in Xcode project added.
- XcodeGen project spec retained for regeneration.
- SwiftUI home flow implemented.
- Photos video picker implemented.
- Video metadata reader implemented.
- AVFoundation compression pipeline implemented.
- Preset selection implemented.
- Save-to-Photos implemented.
- System share sheet export implemented.

Not done:

- Share Extension and App Intents are not implemented.
- Custom bitrate UI is not implemented.
- Broader real-video regression coverage is still needed.

## First commands on the development machine

```bash
cd /path/to/sardine-ios
open Sardine.xcodeproj
```

Use XcodeGen only when the project needs to be regenerated:

```bash
brew install xcodegen
xcodegen generate
```

## Next implementation target

Keep the existing local compression path stable, then add one integration surface at a time. Prefer Share Extension before Shortcuts, because it fits the user behavior of starting from a video in Photos.

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

- add a small manual regression set of real homework videos;
- record before size, after size, compression time, selected preset, and readability notes.

M2:

- add Share Extension from Photos / Files into the existing compression flow.

M3:

- add App Intents / Shortcuts only after the Share Extension behavior is stable.
