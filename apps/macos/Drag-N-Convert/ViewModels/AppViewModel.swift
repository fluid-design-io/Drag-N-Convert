import SwiftUI
import VIPS

@MainActor
class AppViewModel: ObservableObject {
  @Published var state: AppState
  @Published var currentBatch: ConversionBatch?
  @Published var draggedFileURLs: [URL] = []

  private let stateManager: StateManager
  private var mockConversionTask: Task<Void, Never>?

  private static let defaultPresets = [
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
    ConversionPreset(
      nickname: "Mobile HEIC",
      maxWidth: 1280,
      maxHeight: 720,
      format: .heif,
      quality: 80
    ),
  ]

  init(stateManager: StateManager = StateManager()) {
    self.stateManager = stateManager
    self.state = stateManager.loadState()

    if state.presets.isEmpty {
      state.presets = Self.defaultPresets
      saveState()
    }
  }

  // MARK: - Mock Data
  static func mockEmpty() -> AppViewModel {
    let vm = AppViewModel()
    return vm
  }

  static func mockWithPresets() -> AppViewModel {
    let vm = AppViewModel()
    vm.state = AppState(presets: defaultPresets)
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

  private func createTempDirectory() -> URL? {
    let tempDir = FileManager.default.temporaryDirectory
      .appendingPathComponent("DragNConvert-\(UUID().uuidString)")
    try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    return tempDir
  }

  func clearTempFiles() {
    if let tempDir = currentBatch?.tempDirectory {
      try? FileManager.default.removeItem(at: tempDir)
    }
    currentBatch = nil
  }

  func handleFilesDropped(_ urls: [URL], preset: ConversionPreset) {
    let tasks = urls.map { ConversionTask(sourceURL: $0, preset: preset) }
    let tempDir = createTempDirectory()

    // Determine output directory based on preset settings
    let outputDirectory: URL? = {
      switch preset.outputLocation {
      case .temporary:
        return nil
      case .sourceDirectory:
        return urls.first?.deletingLastPathComponent()
      case .custom:
        return preset.customOutputPath.map { URL(fileURLWithPath: $0) }
      }
    }()

    currentBatch = ConversionBatch(
      tasks: tasks,
      outputDirectory: outputDirectory,
      tempDirectory: tempDir
    )

    state.lastUsedPresetId = preset.id
    saveState()

    startConversion()
  }

  private func saveImageData(
    processedImage: VIPSImage, to url: URL, format: ConversionPreset.ImageFormat, quality: Int
  ) throws {
    switch format {
    case .jpeg:
      let jpegData = try processedImage.exportedJpeg(
        quality: quality,
        optimizeCoding: true,
        interlace: true,
        strip: true
      )
      try Data(jpegData).write(to: url)

    case .png:
      let pngData = try processedImage.exportedPNG()
      try Data(pngData).write(to: url)

    case .webp:
      let webpData = try processedImage.exported(
        suffix: ".webp"
      )
      try Data(webpData).write(to: url)

    case .heif:
      let heifData = try processedImage.exported(
        suffix: ".heic"
      )
      try Data(heifData).write(to: url)
    }
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

          // Save to temp directory
          let tempURL = batch.tempDirectory?
            .appendingPathComponent(outputFilename)
            .appendingPathExtension(outputExtension)

          if let tempURL = tempURL {
            // Save to temp directory first
            try saveImageData(
              processedImage: processedImage,
              to: tempURL,
              format: task.preset.format,
              quality: task.preset.quality
            )
            task.outputURL = tempURL

            // Save to output directory if specified
            if let outputURL = batch.outputDirectory?
              .appendingPathComponent(outputFilename)
              .appendingPathExtension(outputExtension)
            {
              try FileManager.default.copyItem(at: tempURL, to: outputURL)
            }

            task.status = .completed
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
