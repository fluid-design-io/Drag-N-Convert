import AppKit
import SwiftUI

struct PresetDropZoneView: View {
  let preset: ConversionPreset
  let isHovered: Bool

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  private var gradientColors: [Color] {
    let baseColor = isHovered ? Color.accentColor : Color.secondary
    return [
      baseColor.opacity(0.04),
      baseColor.opacity(0.12),
    ]
  }

  private var borderColor: Color {
    isHovered ? .accentColor : .secondary.opacity(0.1)
  }

  private var borderWidth: CGFloat {
    isHovered ? 2 : 0.5
  }

  private var locationText: String {
    switch preset.outputLocation {
    case .temporary:
      return "Temp Only"
    case .sourceDirectory:
      return "Same as Source"
    case .custom:
      return preset.customOutputPath ?? "Custom"
    }
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 6) {
        Text(preset.nickname)
          .font(.system(.subheadline, design: .rounded, weight: .medium))
          .lineLimit(1)

        LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
          PresetInfoRow(title: "F", value: "\(preset.format.rawValue.uppercased())")
          PresetInfoRow(title: "Q", value: "\(preset.quality)")
          PresetInfoRow(title: "W", value: "\(preset.maxWidth)")
          PresetInfoRow(title: "H", value: "\(preset.maxHeight)")
        }
        PresetInfoRow(title: "L", value: "\(locationText)")
      }
      Spacer()
    }
    .padding(20)
    .frame(minWidth: 132, maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 30, style: .continuous)
        .fill(
          LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .top,
            endPoint: .bottom
          )
        )
    }
    .overlay {
      RoundedRectangle(cornerRadius: 30, style: .continuous)
        .strokeBorder(borderColor, lineWidth: borderWidth)
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
