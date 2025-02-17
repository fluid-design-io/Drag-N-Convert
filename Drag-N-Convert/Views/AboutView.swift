import SwiftUI

struct AboutView: View {
  private let appVersion =
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
  private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

  var body: some View {
    VStack(spacing: 20) {
      Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
        .resizable()
        .frame(width: 160, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

      Text("Drag-N-Convert")
        .font(.system(.title, design: .rounded, weight: .bold))

      Text("Version \(appVersion) (\(buildNumber))")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Text("A simple and efficient image converter for macOS.")
        .font(.body)
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)

      VStack(spacing: 8) {
        Link(
          "GitHub Repository",
          destination: URL(string: "https://github.com/fluid-design-io/drag-n-convert")!
        )
        .buttonStyle(.link)

        Link(
          "Report an Issue",
          destination: URL(string: "https://github.com/fluid-design-io/drag-n-convert/issues")!
        )
        .buttonStyle(.link)
      }

      Text("© 2025 Oliver Pan. All rights reserved.")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(width: 320)
    .padding(32)
  }
}

#Preview {
  AboutView()
    .frame(width: 400, height: 400)
}
