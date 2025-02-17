import SwiftUI

struct PresetInfoRow: View {
  let title: String  // An "1 letter" string representing the type of info, e.g. "w" for width
  let value: String

  var body: some View {
    HStack(spacing: 4) {
      Text(title)
            .font(.system(.caption, design: .rounded, weight: .semibold))
        .foregroundColor(.secondary)
        .monospaced()
        .padding(4)
        .background{
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                .secondary.opacity(0.06),
                                .secondary.opacity(0.12)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }

      Text(value)
        .font(.system(.subheadline, design: .rounded))
        .foregroundColor(.secondary)
        .monospaced()
        .lineLimit(1)
        .truncationMode(.middle)
    }
  }
}

#Preview("Preset Info Row", traits: .fixedLayout(width: 300, height: 200)) {
    VStack(alignment:.leading, spacing: 8) {
    PresetInfoRow(title: "F", value: "PNG")
    PresetInfoRow(title: "W", value: "1920")
    PresetInfoRow(title: "H", value: "1080")
    PresetInfoRow(title: "Q", value: "85")
        PresetInfoRow(title: "L", value: "Current Location")
  }
  .padding()
  .background(.background)
}
