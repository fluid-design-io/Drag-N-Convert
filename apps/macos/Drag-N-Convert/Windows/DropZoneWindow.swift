import SwiftUI

// MARK: - Window Scene
struct DropZoneWindow: Scene {
  @ObservedObject var windowManager: WindowManager
  @ObservedObject var viewModel: AppViewModel

  init(viewModel: AppViewModel, windowManager: WindowManager) {
    self.viewModel = viewModel
    self.windowManager = windowManager
  }

  var body: some Scene {
    Window("Drop Zone", id: "dropzone") {
      DropZoneView()
        .environmentObject(viewModel)
        .windowVisibility(windowManager.isDropZoneVisible)
    }
    .defaultPosition(.trailing)
    .defaultSize(width: 436, height: 200)
    .windowStyle(.plain)
    .windowLevel(.floating)
    .windowResizability(.contentSize)
    .restorationBehavior(.disabled)
  }
}

#Preview("Drop Zone - Empty") {
  DropZoneView()
    .environmentObject(AppViewModel.mockEmpty())
    .frame(width: 420)
    .background(.background)
}

#Preview("Drop Zone - With Presets") {
  DropZoneView()
    .environmentObject(AppViewModel.mockWithPresets())
    .frame(width: 420)
    .background(.background)
}

#Preview("Drop Zone - Converting") {
  DropZoneView()
    .environmentObject(
      {
        let vm = AppViewModel.mockWithPresets()
        vm.currentBatch = ConversionBatch(
          tasks: [
            ConversionTask(
              sourceURL: URL(fileURLWithPath: "/test1.jpg"),
              preset: ConversionPreset(),
              status: .converting,
              progress: 0.7
            ),
            ConversionTask(
              sourceURL: URL(fileURLWithPath: "/test2.jpg"),
              preset: ConversionPreset()
            ),
          ],
          startTime: Date()
        )
        return vm
      }()
    )
    .frame(width: 420)
    .background(.background)
}

#Preview("Drop Zone - Completed") {
  DropZoneView()
    .environmentObject(
      {
        let vm = AppViewModel.mockWithPresets()
        vm.currentBatch = ConversionBatch(
          tasks: [
            ConversionTask(
              sourceURL: URL(fileURLWithPath: "/test1.jpg"),
              preset: ConversionPreset(),
              status: .completed,
              progress: 1.0,
              outputURL: URL(fileURLWithPath: "/temp/test1.png")
            ),
            ConversionTask(
              sourceURL: URL(fileURLWithPath: "/test2.jpg"),
              preset: ConversionPreset(),
              status: .completed,
              progress: 1.0,
              outputURL: URL(fileURLWithPath: "/temp/test2.png")
            ),
          ],
          startTime: Date().addingTimeInterval(-5),
          endTime: Date(),
          tempDirectory: URL(fileURLWithPath: "/temp")
        )
        return vm
      }()
    )
    .frame(width: 420)
    .background(.background)
}

#Preview("Drop Zone - Failed") {
  DropZoneView()
    .environmentObject(
      {
        let vm = AppViewModel.mockWithPresets()
        vm.currentBatch = ConversionBatch(
          tasks: [
            ConversionTask(
              sourceURL: URL(fileURLWithPath: "/test1.jpg"),
              preset: ConversionPreset(),
              status: .failed,
              progress: 0.5,
              error: NSError(domain: "TestError", code: -1)
            )
          ],
          startTime: Date().addingTimeInterval(-3),
          endTime: Date()
        )
        return vm
      }()
    )
    .frame(width: 420)
    .background(.background)
}
