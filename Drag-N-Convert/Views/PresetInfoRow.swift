import SwiftUI

struct PresetInfoRow: View {
  let title: String  // An "1 letter" string representing the type of info, e.g. "w" for width
  let value: String

  var body: some View {
    HStack(spacing: 4) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .monospaced()
        .padding(4)
        .background(.ultraThinMaterial)
        .cornerRadius(4)

      Text(value)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .monospaced()
    }
  }
}

#Preview("Preset Info Row") {
  VStack(spacing: 8) {
    PresetInfoRow(title: "F", value: "PNG")
    PresetInfoRow(title: "W", value: "1920w")
    PresetInfoRow(title: "H", value: "1080h")
    PresetInfoRow(title: "Q", value: "85")
  }
  .padding()
  .background(.background)
}
