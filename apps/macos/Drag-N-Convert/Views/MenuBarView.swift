import SwiftUI

struct MenuBarView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @EnvironmentObject private var windowManager: WindowManager
  @Environment(\.openWindow) private var openWindow
  @Environment(\.dismissWindow) private var dismissWindow

  var body: some View {
    Button("Presets…") {
      // Bring the app to the front.
      NSApplication.shared.activate(ignoringOtherApps: true)
      openWindow(id: "presets")
    }
    .keyboardShortcut("p")
    .onAppear {
      print("🎯 Setting up window management from MenuBarView")
      windowManager.openWindow = { openWindow(id: $0) }
      windowManager.dismissWindow = { dismissWindow(id: $0) }
    }
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
