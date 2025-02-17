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

  init() {
    let vm = AppViewModel()
    self._viewModel = StateObject(wrappedValue: vm)
    self._windowManager = StateObject(wrappedValue: WindowManager(viewModel: vm))
  }

  var body: some Scene {
      MenuBarExtra(
        String(localized: "[App Name]"),
        systemImage: "arrow.triangle.2.circlepath"
      ) {
      MenuBarView()
        .environmentObject(viewModel)
    }
    .menuBarExtraStyle(.menu)

    Window("Presets", id: "presets") {
      PresetsView()
        .environmentObject(viewModel)
        .windowMinimizeBehavior(.disabled)
    }
    .windowResizability(.contentSize)
    .restorationBehavior(.disabled)

    Window("About Drag-N-Convert", id: "about") {
      AboutView()
        .toolbar(removing: .title)
        .toolbarBackground(.hidden, for: .windowToolbar)
        .containerBackground(.thickMaterial, for: .window)
        .windowMinimizeBehavior(.disabled)
    }
    .windowResizability(.contentSize)
    .restorationBehavior(.disabled)
  }
}
