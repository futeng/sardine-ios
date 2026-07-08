import CoreTransferable
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedVideoItem: PhotosPickerItem?
    @State private var noticeMessage: String?
    @State private var isSavingToPhotos = false

    private let photoLibrarySaver = PhotoLibrarySaver()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    hero
                    metadataSection
                    presetSection
                    progressSection
                    resultSection
                }
                .padding(20)
            }
            .navigationTitle("沙丁鱼")
            .onChange(of: selectedVideoItem) { item in
                guard let item else { return }
                Task {
                    await importAndCompress(item)
                }
            }
            .alert("沙丁鱼", isPresented: noticeBinding) {
                Button("知道了", role: .cancel) {
                    noticeMessage = nil
                }
            } message: {
                Text(noticeMessage ?? "")
            }
        }
    }

    private var noticeBinding: Binding<Bool> {
        Binding(
            get: { noticeMessage != nil },
            set: { isPresented in
                if !isPresented {
                    noticeMessage = nil
                }
            }
        )
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 16) {
                BrandAvatarImage()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Sardine")
                        .font(.largeTitle.bold())
                    Text("把作业视频压小，但别把字压糊。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            PhotosPicker(selection: $selectedVideoItem, matching: .videos) {
                Label("选择视频", systemImage: "video.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(appState.isCompressing)
        }
    }

    @ViewBuilder
    private var metadataSection: some View {
        if let metadata = appState.selectedMetadata {
            VStack(alignment: .leading, spacing: 10) {
                Text("源视频")
                    .font(.title3.bold())

                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                    GridRow {
                        Text("时长")
                        Text(formatDuration(metadata.duration))
                            .foregroundStyle(.secondary)
                    }
                    GridRow {
                        Text("尺寸")
                        Text("\(Int(metadata.displaySize.width)) x \(Int(metadata.displaySize.height))")
                            .foregroundStyle(.secondary)
                    }
                    GridRow {
                        Text("帧率")
                        Text("\(Int(metadata.frameRate.rounded())) fps")
                            .foregroundStyle(.secondary)
                    }
                    GridRow {
                        Text("体积")
                        Text(formatBytes(metadata.fileSize))
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline)
            }
        }
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("压缩档位")
                .font(.title2.bold())

            ForEach(appState.presets) { preset in
                PresetCard(
                    preset: preset,
                    isSelected: preset.id == appState.selectedPreset.id
                ) {
                    appState.selectedPreset = preset
                }
            }
        }
    }

    @ViewBuilder
    private var progressSection: some View {
        if appState.isCompressing {
            VStack(alignment: .leading, spacing: 10) {
                Text("正在压缩")
                    .font(.title3.bold())
                ProgressView(value: appState.progress)
                Text("\(Int((appState.progress * 100).rounded()))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else if let errorMessage = appState.errorMessage {
            Text(errorMessage)
                .font(.subheadline)
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if let result = appState.recentResult {
            VStack(alignment: .leading, spacing: 12) {
                Text("压缩结果")
                    .font(.title3.bold())

                HStack {
                    Text(formatBytes(result.originalSize))
                    Image(systemName: "arrow.right")
                    Text(formatBytes(result.compressedSize))
                        .fontWeight(.semibold)
                }
                .font(.headline)

                Text("压缩比例 \(Int((1 - result.compressionRatio) * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    Task {
                        await saveToPhotos(result.outputURL)
                    }
                } label: {
                    if isSavingToPhotos {
                        Label("正在保存到相册", systemImage: "photo.badge.arrow.down")
                            .frame(maxWidth: .infinity)
                    } else {
                        Label("保存到相册", systemImage: "photo.badge.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isSavingToPhotos)

                ShareLink(item: result.outputURL) {
                    Label("保存到文件或转发", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    noticeMessage = "系统分享面板已打开。保存到文件或转发完成后，回到沙丁鱼即可继续。"
                })
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    private func saveToPhotos(_ url: URL) async {
        isSavingToPhotos = true
        defer {
            isSavingToPhotos = false
        }

        do {
            try await photoLibrarySaver.saveVideo(at: url)
            noticeMessage = "已保存到相册。你可以在“照片”里查看压缩后的视频。"
        } catch {
            noticeMessage = "保存失败：\(error.localizedDescription)"
        }
    }

    private func importAndCompress(_ item: PhotosPickerItem) async {
        do {
            guard let pickedVideo = try await item.loadTransferable(type: PickedVideo.self) else {
                appState.errorMessage = SardineError.unsupportedVideo.localizedDescription
                return
            }

            await appState.compressVideo(at: pickedVideo.url)
            selectedVideoItem = nil
        } catch {
            appState.errorMessage = error.localizedDescription
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }

    private func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

private struct BrandAvatarImage: View {
    var body: some View {
        if let image = UIImage(named: "BrandAvatar") ?? UIImage(named: "sardine-avatar-256") {
            Image(uiImage: image)
                .resizable()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            Image(systemName: "film.stack.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

private struct PickedVideo: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { receivedFile in
            try TemporaryFileStore.prepareTemporaryDirectory()

            let destinationURL = TemporaryFileStore.importedVideoURL(
                filename: receivedFile.file.lastPathComponent
            )

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }

            try FileManager.default.copyItem(at: receivedFile.file, to: destinationURL)
            return PickedVideo(url: destinationURL)
        }
    }
}
