import SwiftUI

struct MenuBarView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    Button("Presets…") {
      // Bring the app to the front.
      NSApplication.shared.activate(ignoringOtherApps: true)
      openWindow(id: "presets")
    }
    .keyboardShortcut("p")
    Divider()
      Button("About \(String(localized: "[App Name]"))") {
      openWindow(id: "about")
    }
    Divider()
    Button("Quit \(String(localized: "[App Name]"))") {
      NSApplication.shared.terminate(nil)
    }
    .keyboardShortcut("q")
  }
}

#Preview("Menu Bar View") {
  MenuBarView()
    .environmentObject(AppViewModel.mockWithPresets())
}
