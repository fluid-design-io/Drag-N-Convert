import SwiftUI

struct AboutView: View {
  private let appVersion =
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
  private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

  var body: some View {
    HStack(spacing: 24) {
      Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
        .resizable()
        .frame(width: 160, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
      VStack(alignment: .leading, spacing: 6) {

        Text(String(localized: "[App Name]"))
          .font(.system(.largeTitle, design: .rounded, weight: .bold))

        Text("Version \(appVersion) (\(buildNumber))")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        VStack(alignment: .leading, spacing: 8) {
          Text("A simple and efficient image converter for macOS.")
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

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

          HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
              Text("Author")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.top, 8)

              Link(
                "Oliver Pan",
                destination: URL(string: "https://oliverpan.vercel.app")!
              )
              .font(.caption)
              .buttonStyle(.link)
            }
            VStack(alignment: .leading, spacing: 6) {
              Text("Credits")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.top, 8)

              Link(
                "SwiftVips",
                destination: URL(string: "https://github.com/gh123man/SwiftVips")!
              )
              .font(.caption)
              .buttonStyle(.link)
            }
          }
        }
        .padding(.top, 16)

      }
      .padding()
    }
    .padding(.horizontal, 36)
    .padding(.top, 24)
    .padding(.bottom, 36)
    .frame(width: 540)
  }
}

#Preview {
  AboutView()
}
