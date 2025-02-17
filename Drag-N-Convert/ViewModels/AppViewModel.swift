import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
  @Published private(set) var state: AppState
  @Published var currentBatch: ConversionBatch?
  @Published var isDropZoneVisible = false
  @Published var draggedFileURLs: [URL] = []

  private let stateManager: StateManager
  private var mockConversionTask: Task<Void, Never>?

  init(stateManager: StateManager = StateManager()) {
    self.stateManager = stateManager
    self.state = stateManager.loadState()
  }

  // MARK: - Mock Data
  static func mockEmpty() -> AppViewModel {
    let vm = AppViewModel()
    return vm
  }

  static func mockWithPresets() -> AppViewModel {
    let vm = AppViewModel()
    vm.state = AppState(presets: [
      ConversionPreset(
        nickname: "4K PNG",
        maxWidth: 3840,
        maxHeight: 2160,
        format: .png,
        quality: 90
      ),
      ConversionPreset(
        nickname: "HD WEBP",
        maxWidth: 1920,
        maxHeight: 1080,
        format: .webp,
        quality: 85
      ),
      ConversionPreset(
        nickname: "Mobile JPEG",
        maxWidth: 1280,
        maxHeight: 720,
        format: .jpeg,
        quality: 80
      ),
    ])
    return vm
  }

  static func mockConverting() -> AppViewModel {
    let vm = AppViewModel()
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
  }

  func addPreset(_ preset: ConversionPreset) {
    state.presets.append(preset)
    saveState()
  }

  func updatePreset(_ preset: ConversionPreset) {
    if let index = state.presets.firstIndex(where: { $0.id == preset.id }) {
      state.presets[index] = preset
      saveState()
    }
  }

  func deletePreset(_ preset: ConversionPreset) {
    state.presets.removeAll { $0.id == preset.id }
    saveState()
  }

  func deletePresetAtIndexSet(_ indexSet: IndexSet) {
    state.presets.remove(atOffsets: indexSet)
    saveState()
  }

  func movePresets(from source: IndexSet, to destination: Int) {
    state.presets.move(fromOffsets: source, toOffset: destination)
    saveState()
  }

  func handleFilesDropped(_ urls: [URL], preset: ConversionPreset) {
    let tasks = urls.map { ConversionTask(sourceURL: $0, preset: preset) }

    // Create output directory in Desktop/Converted
    let outputDirectory = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
      .first?
      .appendingPathComponent("Converted", isDirectory: true)

    currentBatch = ConversionBatch(
      tasks: tasks,
      outputDirectory: outputDirectory
    )

    state.lastUsedPresetId = preset.id
    saveState()

    startConversion()
  }

  func startConversion() {
    guard let batch = currentBatch else { return }

    // Cancel any existing conversion
    mockConversionTask?.cancel()

    mockConversionTask = Task {
      // Simulate conversion process
      var updatedBatch = batch
      updatedBatch.startTime = Date()

      // Update status to converting
      for i in 0..<updatedBatch.tasks.count {
        updatedBatch.tasks[i].status = .converting
      }
      currentBatch = updatedBatch

      // Simulate progress for each task
      for taskIndex in 0..<updatedBatch.tasks.count {
        guard !Task.isCancelled else { return }

        // Simulate progress updates
        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
          guard !Task.isCancelled else { return }

          try? await Task.sleep(nanoseconds: 200_000_000)  // 0.2 seconds

          updatedBatch.tasks[taskIndex].progress = progress
          currentBatch = updatedBatch
        }

        // Randomly simulate success/failure (90% success rate)
        if Double.random(in: 0...1) < 0.9 {
          updatedBatch.tasks[taskIndex].status = .completed
        } else {
          updatedBatch.tasks[taskIndex].status = .failed
          updatedBatch.tasks[taskIndex].error = NSError(
            domain: "MockError", code: -1,
            userInfo: [
              NSLocalizedDescriptionKey: "Mock conversion error"
            ])
        }
        currentBatch = updatedBatch
      }

      updatedBatch.endTime = Date()
      currentBatch = updatedBatch
    }
  }

  private func saveState() {
    stateManager.saveState(state)
  }
}

// MARK: - Drag and Drop
extension AppViewModel {
  func validateDrop(urls: [URL]) -> Bool {
    // Accept only image files
    let validExtensions = ["jpg", "jpeg", "png", "gif", "heic", "webp"]
    return urls.allSatisfy { url in
      validExtensions.contains(url.pathExtension.lowercased())
    }
  }
}
