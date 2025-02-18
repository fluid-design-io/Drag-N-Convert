import SwiftUI
import VIPS

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

    // Use preset's output path if available, otherwise use source directory
    let outputDirectory: URL? =
      if let customPath = preset.outputPath {
        URL(fileURLWithPath: customPath, isDirectory: true)
      } else {
        urls.first?.deletingLastPathComponent()
      }

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
      var updatedBatch = batch
      updatedBatch.startTime = Date()

      // Create output directory if it doesn't exist
      if let outputDir = batch.outputDirectory {
        try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
      }

      // Process each task
      for taskIndex in 0..<updatedBatch.tasks.count {
        guard !Task.isCancelled else { return }

        var task = updatedBatch.tasks[taskIndex]
        task.status = .converting
        updatedBatch.tasks[taskIndex] = task
        currentBatch = updatedBatch

        do {
          // Load the image with sequential access for better performance
          let image = try VIPSImage(fromFilePath: task.sourceURL.path)

          // Calculate new dimensions while maintaining aspect ratio
          let newDimensions = calculateNewDimensions(
            currentWidth: image.size.width,
            currentHeight: image.size.height,
            maxWidth: task.preset.maxWidth,
            maxHeight: task.preset.maxHeight
          )

          // Resize image without cropping
          let processedImage = try image.thumbnailImage(
            width: newDimensions.width,
            height: newDimensions.height,
            crop: .none  // Changed from .attention to .none
          )

          // Update progress
          task.progress = 0.5
          updatedBatch.tasks[taskIndex] = task
          currentBatch = updatedBatch

          // Prepare output filename
          let outputFilename = task.sourceURL.deletingPathExtension().lastPathComponent
          let outputExtension = task.preset.format.rawValue
          let outputURL = batch.outputDirectory?
            .appendingPathComponent(outputFilename)
            .appendingPathExtension(outputExtension)

          if let outputURL = outputURL {
            // Export with format-specific options
            switch task.preset.format {
            case .jpeg:
              let jpegData = try processedImage.exportedJpeg(
                quality: Int(task.preset.quality),
                optimizeCoding: true,
                interlace: true,
                strip: true
              )
              try Data(jpegData).write(to: outputURL)
            case .png:
              let pngData = try processedImage.exportedPNG()
              try Data(pngData).write(to: outputURL)
            case .webp:
              let webpData = try processedImage.exported(
                suffix: ".webp"
              )
              try Data(webpData).write(to: outputURL)
            case .heif:
              let heifData = try processedImage.exported(
                suffix: ".heic"
              )
              try Data(heifData).write(to: outputURL)
            }

            task.status = .completed
          } else {
            throw NSError(
              domain: "AppError",
              code: -1,
              userInfo: [NSLocalizedDescriptionKey: "Invalid output path"]
            )
          }

        } catch {
          task.status = .failed
          task.error = error
        }

        task.progress = 1.0
        updatedBatch.tasks[taskIndex] = task
        currentBatch = updatedBatch
      }

      updatedBatch.endTime = Date()
      currentBatch = updatedBatch
    }
  }

  private func calculateNewDimensions(
    currentWidth: Int, currentHeight: Int, maxWidth: Int, maxHeight: Int
  ) -> (width: Int, height: Int) {
    let widthRatio = Double(maxWidth) / Double(currentWidth)
    let heightRatio = Double(maxHeight) / Double(currentHeight)
    let scale = min(widthRatio, heightRatio, 1.0)

    return (
      width: Int(Double(currentWidth) * scale),
      height: Int(Double(currentHeight) * scale)
    )
  }

  private func saveState() {
    stateManager.saveState(state)
  }
}

// MARK: - Drag and Drop
extension AppViewModel {
  func validateDrop(urls: [URL]) -> Bool {
    // Accept only image files
    let validExtensions = ["jpg", "jpeg", "png", "heic", "webp"]
    return urls.allSatisfy { url in
      validExtensions.contains(url.pathExtension.lowercased())
    }
  }
}
