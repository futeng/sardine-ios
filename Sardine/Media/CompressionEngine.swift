@preconcurrency import AVFoundation
import CoreGraphics
import Foundation

struct CompressionProgress: Equatable {
    let fractionCompleted: Double
}

protocol VideoCompressing {
    func compress(
        job: CompressionJob,
        progress: @escaping @Sendable (CompressionProgress) -> Void
    ) async throws -> CompressionResult
}

final class CompressionEngine: VideoCompressing {
    func compress(
        job: CompressionJob,
        progress: @escaping @Sendable (CompressionProgress) -> Void
    ) async throws -> CompressionResult {
        progress(CompressionProgress(fractionCompleted: 0))

        let asset = AVURLAsset(url: job.sourceURL)
        let duration = try await asset.load(.duration)
        let tracks = try await asset.load(.tracks)

        guard let videoTrack = tracks.first(where: { $0.mediaType == .video }) else {
            throw SardineError.missingVideoTrack
        }

        let naturalSize = try await videoTrack.load(.naturalSize)
        let preferredTransform = try await videoTrack.load(.preferredTransform)
        let displaySize = VideoGeometry.displaySize(
            naturalSize: naturalSize,
            preferredTransform: preferredTransform
        )
        let outputSize = VideoGeometry.outputSize(
            displaySize: displaySize,
            maxLongSide: CGFloat(job.preset.maxLongSide)
        )

        try removeExistingFile(at: job.outputURL)

        let reader = try AVAssetReader(asset: asset)
        let writer = try AVAssetWriter(outputURL: job.outputURL, fileType: .mp4)
        writer.shouldOptimizeForNetworkUse = true

        let videoOutput = AVAssetReaderVideoCompositionOutput(
            videoTracks: [videoTrack],
            videoSettings: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
            ]
        )
        videoOutput.alwaysCopiesSampleData = false
        videoOutput.videoComposition = makeVideoComposition(
            videoTrack: videoTrack,
            naturalSize: naturalSize,
            preferredTransform: preferredTransform,
            outputSize: outputSize,
            duration: duration,
            maxFrameRate: job.preset.maxFrameRate
        )

        guard reader.canAdd(videoOutput) else {
            throw SardineError.cannotCreateReader
        }
        reader.add(videoOutput)

        let videoInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: videoSettings(for: job.preset, outputSize: outputSize)
        )
        videoInput.expectsMediaDataInRealTime = false
        guard writer.canAdd(videoInput) else {
            throw SardineError.cannotCreateWriter
        }
        writer.add(videoInput)

        let audioTrack = tracks.first(where: { $0.mediaType == .audio })
        let audioSourceFormatHint = try await audioTrack?.load(.formatDescriptions).first
        let audioPair = makeAudioPair(
            audioTrack: audioTrack,
            sourceFormatHint: audioSourceFormatHint,
            reader: reader,
            writer: writer,
            preset: job.preset
        )

        guard writer.startWriting(), reader.startReading() else {
            reader.cancelReading()
            writer.cancelWriting()
            throw writer.error ?? reader.error ?? SardineError.compressionFailed
        }
        writer.startSession(atSourceTime: .zero)

        try await writeSamples(
            videoOutput: videoOutput,
            videoInput: videoInput,
            audioOutput: audioPair?.output,
            audioInput: audioPair?.input,
            reader: reader,
            writer: writer,
            duration: duration,
            progress: progress
        )

        let compressedSize = fileSize(for: job.outputURL)
        let originalSize = fileSize(for: job.sourceURL)

        progress(CompressionProgress(fractionCompleted: 1))

        return CompressionResult(
            sourceURL: job.sourceURL,
            outputURL: job.outputURL,
            originalSize: originalSize,
            compressedSize: compressedSize,
            duration: CMTimeGetSeconds(duration),
            preset: job.preset
        )
    }

    private func makeAudioPair(
        audioTrack: AVAssetTrack?,
        sourceFormatHint: CMFormatDescription?,
        reader: AVAssetReader,
        writer: AVAssetWriter,
        preset: CompressionPreset
    ) -> (output: AVAssetReaderTrackOutput, input: AVAssetWriterInput)? {
        guard let audioTrack else {
            return nil
        }

        switch preset.audioMode {
        case .passthroughPreferred:
            return makeAudioPair(
                audioTrack: audioTrack,
                outputSettings: nil,
                inputSettings: nil,
                sourceFormatHint: sourceFormatHint,
                reader: reader,
                writer: writer
            ) ?? makeAudioPair(
                audioTrack: audioTrack,
                outputSettings: linearPCMAudioSettings(),
                inputSettings: aacAudioSettings(bitRate: preset.fallbackAudioBitrate),
                sourceFormatHint: nil,
                reader: reader,
                writer: writer
            )
        case .aac64k, .aac96k, .aac128k:
            return makeAudioPair(
                audioTrack: audioTrack,
                outputSettings: linearPCMAudioSettings(),
                inputSettings: aacAudioSettings(bitRate: preset.fallbackAudioBitrate),
                sourceFormatHint: nil,
                reader: reader,
                writer: writer
            )
        }
    }

    private func makeAudioPair(
        audioTrack: AVAssetTrack,
        outputSettings: [String: Any]?,
        inputSettings: [String: Any]?,
        sourceFormatHint: CMFormatDescription?,
        reader: AVAssetReader,
        writer: AVAssetWriter
    ) -> (output: AVAssetReaderTrackOutput, input: AVAssetWriterInput)? {
        let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        audioOutput.alwaysCopiesSampleData = false
        let audioInput = AVAssetWriterInput(
            mediaType: .audio,
            outputSettings: inputSettings,
            sourceFormatHint: sourceFormatHint
        )
        audioInput.expectsMediaDataInRealTime = false

        guard reader.canAdd(audioOutput), writer.canAdd(audioInput) else {
            return nil
        }

        reader.add(audioOutput)
        writer.add(audioInput)
        return (audioOutput, audioInput)
    }

    private func writeSamples(
        videoOutput: AVAssetReaderOutput,
        videoInput: AVAssetWriterInput,
        audioOutput: AVAssetReaderOutput?,
        audioInput: AVAssetWriterInput?,
        reader: AVAssetReader,
        writer: AVAssetWriter,
        duration: CMTime,
        progress: @escaping @Sendable (CompressionProgress) -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let group = DispatchGroup()
            let state = SampleWritingState()
            let durationSeconds = max(CMTimeGetSeconds(duration), 0)
            let readerBox = UncheckedSendableBox(reader)
            let writerBox = UncheckedSendableBox(writer)
            let videoOutputBox = UncheckedSendableBox(videoOutput)
            let videoInputBox = UncheckedSendableBox(videoInput)
            let audioOutputBox = audioOutput.map(UncheckedSendableBox.init)
            let audioInputBox = audioInput.map(UncheckedSendableBox.init)
            let videoFinisher = SampleTrackFinisher(group: group)
            let audioFinisher = SampleTrackFinisher(group: group)

            group.enter()
            videoInputBox.value.requestMediaDataWhenReady(on: DispatchQueue(label: "sardine.video-writer")) {
                let reader = readerBox.value
                let writer = writerBox.value
                let videoOutput = videoOutputBox.value
                let videoInput = videoInputBox.value

                while videoInput.isReadyForMoreMediaData {
                    if state.isFinished {
                        videoFinisher.finish {
                            videoInput.markAsFinished()
                        }
                        return
                    }

                    guard let sampleBuffer = videoOutput.copyNextSampleBuffer() else {
                        videoFinisher.finish {
                            videoInput.markAsFinished()
                        }
                        return
                    }

                    if durationSeconds > 0 {
                        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        let fraction = CMTimeGetSeconds(presentationTime) / durationSeconds
                        progress(CompressionProgress(fractionCompleted: min(max(fraction, 0), 0.98)))
                    }

                    if !videoInput.append(sampleBuffer) {
                        state.finish(with: writer.error ?? SardineError.compressionFailed)
                        reader.cancelReading()
                        videoFinisher.finish {
                            videoInput.markAsFinished()
                        }
                        return
                    }
                }
            }

            if let audioOutputBox, let audioInputBox {
                group.enter()
                audioInputBox.value.requestMediaDataWhenReady(on: DispatchQueue(label: "sardine.audio-writer")) {
                    let reader = readerBox.value
                    let writer = writerBox.value
                    let audioOutput = audioOutputBox.value
                    let audioInput = audioInputBox.value

                    while audioInput.isReadyForMoreMediaData {
                        if state.isFinished {
                            audioFinisher.finish {
                                audioInput.markAsFinished()
                            }
                            return
                        }

                        guard let sampleBuffer = audioOutput.copyNextSampleBuffer() else {
                            audioFinisher.finish {
                                audioInput.markAsFinished()
                            }
                            return
                        }

                        if !audioInput.append(sampleBuffer) {
                            state.finish(with: writer.error ?? SardineError.compressionFailed)
                            reader.cancelReading()
                            audioFinisher.finish {
                                audioInput.markAsFinished()
                            }
                            return
                        }
                    }
                }
            }

            group.notify(queue: DispatchQueue(label: "sardine.finish-writer")) {
                let reader = readerBox.value
                let writer = writerBox.value

                if let error = state.error {
                    writer.cancelWriting()
                    continuation.resume(throwing: error)
                    return
                }

                if reader.status == .failed || reader.status == .cancelled {
                    writer.cancelWriting()
                    continuation.resume(throwing: reader.error ?? SardineError.compressionFailed)
                    return
                }

                writer.finishWriting {
                    let writer = writerBox.value

                    if writer.status == .failed || writer.status == .cancelled {
                        continuation.resume(throwing: writer.error ?? SardineError.compressionFailed)
                    } else {
                        continuation.resume()
                    }
                }
            }
        }
    }

    private func makeVideoComposition(
        videoTrack: AVAssetTrack,
        naturalSize: CGSize,
        preferredTransform: CGAffineTransform,
        outputSize: CGSize,
        duration: CMTime,
        maxFrameRate: Int
    ) -> AVVideoComposition {
        let composition = AVMutableVideoComposition()
        composition.renderSize = outputSize
        composition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(maxFrameRate))

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstruction.setTransform(
            outputTransform(
                naturalSize: naturalSize,
                preferredTransform: preferredTransform,
                outputSize: outputSize
            ),
            at: .zero
        )
        instruction.layerInstructions = [layerInstruction]
        composition.instructions = [instruction]

        return composition
    }

    private func outputTransform(
        naturalSize: CGSize,
        preferredTransform: CGAffineTransform,
        outputSize: CGSize
    ) -> CGAffineTransform {
        let transformedRect = CGRect(origin: .zero, size: naturalSize).applying(preferredTransform)
        let displaySize = CGSize(width: abs(transformedRect.width), height: abs(transformedRect.height))
        let scale = min(outputSize.width / displaySize.width, outputSize.height / displaySize.height)

        return preferredTransform
            .concatenating(CGAffineTransform(translationX: -transformedRect.minX, y: -transformedRect.minY))
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
    }

    private func videoSettings(for preset: CompressionPreset, outputSize: CGSize) -> [String: Any] {
        [
            AVVideoCodecKey: codec(for: preset.codec),
            AVVideoWidthKey: Int(outputSize.width),
            AVVideoHeightKey: Int(outputSize.height),
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: preset.videoBitrate,
                AVVideoExpectedSourceFrameRateKey: preset.maxFrameRate,
                AVVideoMaxKeyFrameIntervalKey: preset.maxFrameRate
            ]
        ]
    }

    private func linearPCMAudioSettings() -> [String: Any] {
        [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
    }

    private func codec(for codec: VideoCodec) -> AVVideoCodecType {
        switch codec {
        case .hevc:
            return .hevc
        case .h264:
            return .h264
        }
    }

    private func aacAudioSettings(bitRate: Int) -> [String: Any] {
        [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44_100,
            AVEncoderBitRateKey: bitRate
        ]
    }

    private func removeExistingFile(at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }

    private func fileSize(for url: URL) -> Int64 {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        return Int64(values?.fileSize ?? 0)
    }
}

private final class SampleWritingState: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var error: Error?

    var isFinished: Bool {
        lock.lock()
        defer { lock.unlock() }
        return error != nil
    }

    func finish(with error: Error) {
        lock.lock()
        defer { lock.unlock() }
        if self.error == nil {
            self.error = error
        }
    }
}

private final class SampleTrackFinisher: @unchecked Sendable {
    private let group: DispatchGroup
    private let lock = NSLock()
    private var didFinish = false

    init(group: DispatchGroup) {
        self.group = group
    }

    func finish(_ markFinished: () -> Void) {
        lock.lock()
        guard !didFinish else {
            lock.unlock()
            return
        }
        didFinish = true
        lock.unlock()

        markFinished()
        group.leave()
    }
}

private final class UncheckedSendableBox<Value>: @unchecked Sendable {
    let value: Value

    init(_ value: Value) {
        self.value = value
    }
}
