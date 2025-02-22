//
//  Drag_N_ConvertApp.swift
//  Drag-N-Convert
//
//  Created by Oliver Pan on 2/16/25.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct Drag_N_ConvertApp: App {
  @StateObject private var viewModel = AppViewModel()
  @StateObject private var windowManager: WindowManager

  @Environment(\.openWindow) private var openWindow
  @Environment(\.dismissWindow) private var dismissWindow

  init() {
    print("📱 Initializing DragNConvertApp")

    let vm = AppViewModel()
    self._viewModel = StateObject(wrappedValue: vm)
    self._windowManager = StateObject(
      wrappedValue: WindowManager(viewModel: vm)
    )

    print("✅ App initialization complete")
  }

  enum DependencyError: LocalizedError {
    case nodeNotFound

    var errorDescription: String? {
      switch self {
      case .nodeNotFound:
        return
          "Node.js and sharp are required. Please install them using:\n\nbrew install node\nnpm install -g sharp"
      }
    }
  }

  var body: some Scene {
    MenuBarExtra(
      String(localized: "[App Name]"),
      systemImage: "arrow.triangle.2.circlepath"
    ) {
      MenuBarView()
        .environmentObject(viewModel)
        .environmentObject(windowManager)
    }
    .menuBarExtraStyle(.menu)

    Window("Presets", id: "presets") {
      PresetsView()
        .environmentObject(viewModel)
        .windowMinimizeBehavior(.disabled)
    }
    .windowResizability(.contentSize)
    .restorationBehavior(.disabled)

    Window("About \(String(localized: "[App Name]"))", id: "about") {
      AboutView()
        .toolbar(removing: .title)
        .toolbarBackground(.hidden, for: .windowToolbar)
        .containerBackground(.thickMaterial, for: .window)
        .windowMinimizeBehavior(.disabled)
    }
    .windowResizability(.contentSize)
    .restorationBehavior(.disabled)

    DropZoneWindow(
      viewModel: viewModel,
      windowManager: windowManager
    )
  }

}
