# Test Plan

Sardine must be evaluated with real homework videos, not only generic camera clips.

## Required sample set

Prepare at least these videos:

1. Printed English worksheet, vertical, 1080p60.
2. Printed Chinese worksheet, vertical, 1080p30.
3. Handwritten notes, vertical, 1080p30.
4. Workbook page under indoor warm light.
5. Computer screen or PPT, horizontal, 1080p30.
6. Narrated homework explanation with clear voice.
7. 4K60 iPhone source.
8. HDR / Dolby Vision source.
9. ProRes source if available.

## Metrics to record

For each source and preset:

- source file size;
- output file size;
- source duration;
- output duration;
- source frame rate;
- output frame rate;
- output video bitrate;
- output audio bitrate;
- compression time;
- device model;
- iOS version;
- whether text is readable on iPhone full screen;
- whether audio is clear;
- whether audio/video sync is correct;
- whether the result saves to Photos;
- whether the result exports to Files.

## Acceptance criteria

`Homework Clear` preset:

- Text is readable on iPhone full screen for typical worksheets.
- Output stays at 1080p-class resolution unless source is smaller.
- 60fps sources output at 30fps.
- Audio is clear and synchronized.
- Output file is meaningfully smaller than source.
- 1-minute source should usually land around 10–13MB.

`Text Priority` preset:

- Text readability must be better than `Homework Clear`.
- 1-minute source should usually land around 14–17MB.

`Tiny File` preset:

- Must show a quality warning.
- 1-minute source should usually land around 7–9MB.
- Text blur is acceptable only if the user chose this preset knowingly.

## Regression checks

After every compression-engine change:

- portrait orientation remains correct;
- landscape orientation remains correct;
- no black frames at start or end;
- audio is present if source has audio;
- output plays in Photos;
- output can be shared through iOS share sheet;
- temporary files are cleaned after success or failure.

