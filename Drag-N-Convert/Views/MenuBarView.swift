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
    Button("About Drag-N-Convert") {
      openWindow(id: "about")
    }
    Divider()
    Button("Quit DragNConvert") {
      NSApplication.shared.terminate(nil)
    }
    .keyboardShortcut("q")
  }
}

#Preview("Menu Bar View") {
  MenuBarView()
    .environmentObject(AppViewModel.mockWithPresets())
}
