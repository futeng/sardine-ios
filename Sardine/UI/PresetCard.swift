import SwiftUI

struct PresetCard: View {
    let preset: CompressionPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(preset.displayName)
                        .font(.headline)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.tint)
                    }
                }

                Text(preset.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    Label("\(preset.videoBitrate / 1_000_000).\(preset.videoBitrate % 1_000_000 / 100_000) Mbps", systemImage: "speedometer")
                    Label("≤ \(preset.maxFrameRate)fps", systemImage: "film")
                    Label("≤ \(preset.maxLongSide)p", systemImage: "rectangle.compress.vertical")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

