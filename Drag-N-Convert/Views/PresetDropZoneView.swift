import AppKit
import SwiftUI

struct PresetDropZoneView: View {
  let preset: ConversionPreset
  let isHovered: Bool

  var body: some View {
    VStack(spacing: 4) {
      Text(preset.nickname)
        .font(.subheadline)
        .lineLimit(1)

      PresetInfoRow(title: "F", value: preset.format.rawValue.uppercased())
      PresetInfoRow(title: "W", value: "\(preset.maxWidth)w")
      PresetInfoRow(title: "H", value: "\(preset.maxHeight)h")
      PresetInfoRow(title: "Q", value: "\(Int(preset.quality))")
    }
    .padding(.vertical, 16)
    .frame(minWidth: 100, maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(
          isHovered
            ? Color.accentColor.opacity(0.15)
            : .secondary.opacity(0.06)
        )
    }
    .overlay {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .strokeBorder(
          isHovered ? Color.accentColor : .secondary.opacity(0.1),
          lineWidth: isHovered ? 2 : 0.5
        )
    }
    .animation(.easeInOut(duration: 0.15), value: isHovered)
    .onChange(of: isHovered) { oldValue, newValue in
      if newValue {
        NSHapticFeedbackManager.defaultPerformer.perform(
          .alignment, performanceTime: .default)
      }
    }
  }
}

#Preview("Preset Drop Zone") {
  VStack(spacing: 16) {
    PresetDropZoneView(
      preset: ConversionPreset(
        nickname: "4K PNG",
        maxWidth: 3840,
        maxHeight: 2160,
        format: .png,
        quality: 90
      ),
      isHovered: false
    )

    PresetDropZoneView(
      preset: ConversionPreset(
        nickname: "HD WEBP",
        maxWidth: 1920,
        maxHeight: 1080,
        format: .webp,
        quality: 85
      ),
      isHovered: true
    )
  }
  .padding()
  .frame(width: 350)
  .background(.background)
}
