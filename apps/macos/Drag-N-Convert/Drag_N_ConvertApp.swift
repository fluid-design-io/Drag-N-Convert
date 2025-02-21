//
//  Drag_N_ConvertApp.swift
//  Drag-N-Convert
//
//  Created by Oliver Pan on 2/16/25.
//

import SwiftUI
import UniformTypeIdentifiers
import VIPS

@main
struct Drag_N_ConvertApp: App {
  @StateObject private var viewModel = AppViewModel()
  @StateObject private var windowManager: WindowManager

  init() {
    print("📱 Initializing DragNConvertApp")
    // Initialize VIPS
    do {
      try VIPS.start()
      print("✅ VIPS initialized successfully")
    } catch {
      print("❌ Failed to initialize VIPS:", error)
      exit(1)
    }

    let vm = AppViewModel()
    self._viewModel = StateObject(wrappedValue: vm)
    // Initialize with empty actions first
    self._windowManager = StateObject(
      wrappedValue: WindowManager(viewModel: vm))

    print("✅ App initialization complete")
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

    // Add the drop zone window
    DropZoneWindow(
      viewModel: viewModel,
      windowManager: windowManager
    )
  }
}
