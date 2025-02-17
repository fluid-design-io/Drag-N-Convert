import AppKit
import SwiftUI

struct PresetDropZoneView: View {
  let preset: ConversionPreset
  let isHovered: Bool

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(preset.nickname)
          .font(.system(.subheadline, design: .rounded, weight: .medium))
          .lineLimit(1)
          .padding(.bottom, 4)

        LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
          PresetInfoRow(title: "F", value: "\(preset.format.rawValue.uppercased())")
          PresetInfoRow(title: "W", value: "\(Int(preset.maxWidth))")
          PresetInfoRow(title: "H", value: "\(Int(preset.maxHeight))")
          PresetInfoRow(title: "Q", value: "\(Int(preset.quality))")
        }
        if preset.outputPath != nil {
          PresetInfoRow(title: "L", value: "\(preset.outputPath!)")
        } else {
          PresetInfoRow(title: "L", value: "Current Path")
        }
      }
      Spacer()
    }
    .padding()
    .frame(minWidth: 132, maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 30, style: .continuous)
        .fill(
          LinearGradient(
            gradient: Gradient(colors: [
              isHovered
                ? .accentColor.opacity(0.04)
                : Color.secondary.opacity(0.04),
              isHovered
                ? .accentColor.opacity(0.1)
                : Color.secondary.opacity(0.1),
            ]),
            startPoint: .top,
            endPoint: .bottom
          )
        )

    }
    .overlay {
      ZStack {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
          .strokeBorder(
            isHovered ? Color.accentColor : .secondary.opacity(0.1),
            lineWidth: isHovered ? 2 : 0.5
          )
      }
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
  .frame(width: 420)
  .background(.background)
}
