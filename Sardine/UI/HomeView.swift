import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    hero
                    presetSection
                    nextStepSection
                }
                .padding(20)
            }
            .navigationTitle("沙丁鱼")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 16) {
                Image("BrandAvatar")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Sardine")
                        .font(.largeTitle.bold())
                    Text("把作业视频压小，但别把字压糊。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                // TODO: Open PhotosPicker / document picker.
            } label: {
                Label("选择视频", systemImage: "video.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
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

    private var nextStepSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("开发下一步")
                .font(.title3.bold())
            Text("先实现固定路径：选择视频 → 读取元数据 → HEVC 1080p30 1.5Mbps → 导出 MP4。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

