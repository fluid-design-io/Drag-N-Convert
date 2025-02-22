import CoreImage
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class AppViewModel: ObservableObject {
  @Published var state: AppState
  @Published var currentBatch: ConversionBatch?
  @Published var draggedFileURLs: [URL] = []
  @Published var isCloseAfterConversion: Bool?

  private let stateManager: StateManager
  private var conversionTask: Task<Void, Never>?
  private let imageProcessor = ImageProcessor()

  private static let defaultPresets = [
    ConversionPreset(
      nickname: "4K PNG",
      maxWidth: 3840,
      maxHeight: 2160,
      format: .png,
      quality: 90
    ),
    ConversionPreset(
      nickname: "HD WebP",
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
      nickname: "Mobile AVIF",
      maxWidth: 1280,
      maxHeight: 720,
      format: .avif,
      quality: 80
    ),
  ]

  init(stateManager: StateManager = StateManager()) {
    self.stateManager = stateManager
    self.state = stateManager.loadState()

    if state.presets.isEmpty {
      state.presets = Self.defaultPresets
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
  }

  func updatePreset(_ preset: ConversionPreset) {
    if let index = state.presets.firstIndex(where: { $0.id == preset.id }) {
      state.presets[index] = preset
    }
  }

  func deletePreset(_ preset: ConversionPreset) {
    state.presets.removeAll { $0.id == preset.id }
  }

  func deletePresetAtIndexSet(_ indexSet: IndexSet) {
    state.presets.remove(atOffsets: indexSet)
  }

  func movePresets(from source: IndexSet, to destination: Int) {
    state.presets.move(fromOffsets: source, toOffset: destination)
  }

  private func createTempDirectory() -> URL? {
    let tempDir = FileManager.default.temporaryDirectory
      .appendingPathComponent("DragNConvert-\(UUID().uuidString)")
    try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    return tempDir
  }

  func dismissFloatingPanel() {
    print("👋 Dismissing floating panel")
    isCloseAfterConversion = true
  }

  func clearTempFiles() {
    if let tempDir = currentBatch?.tempDirectory {
      try? FileManager.default.removeItem(at: tempDir)
      print("🧹 Cleared temp files")
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

    startConversion()
  }

  func startConversion() {
    guard let batch = currentBatch else { return }

    // Cancel any existing conversion
    conversionTask?.cancel()

    conversionTask = Task {
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
          let outputURL = try await imageProcessor.processImage(
            at: task.sourceURL,
            preset: task.preset,
            outputDirectory: batch.outputDirectory ?? batch.tempDirectory
          )

          task.outputURL = outputURL
          task.status = .completed

          if task.preset.deleteOriginal {
            try? FileManager.default.removeItem(at: task.sourceURL)
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
}

// MARK: - Image Processor
class ImageProcessor {
  private let nodeScriptPath: String
  private let nodeBinaryPath: String
  private let nodeModulesPath: String
  private let fileManager = FileManager.default

  init() {
    if let bundleResourcePath = Bundle.main.resourcePath {
      self.nodeScriptPath = (bundleResourcePath as NSString)
        .appendingPathComponent("image-processor.js")
      let nodePath = (bundleResourcePath as NSString)
        .appendingPathComponent("node")
      self.nodeBinaryPath = (nodePath as NSString)
        .appendingPathComponent("bin/node")
      self.nodeModulesPath = (nodePath as NSString)
        .appendingPathComponent("node_modules")
    } else {
      // Development fallbacks
      self.nodeScriptPath = "scripts/image-processor.js"
      self.nodeBinaryPath = "/usr/local/bin/node"
      self.nodeModulesPath = "/usr/local/lib/node_modules"
    }

    #if DEBUG
      print("🔧 Node paths:")
      print("Script: \(nodeScriptPath)")
      print("Binary: \(nodeBinaryPath)")
      print("Modules: \(nodeModulesPath)")
    #endif
  }

  func processImage(at url: URL, preset: ConversionPreset, outputDirectory: URL?) async throws
    -> URL
  {
    print("🔄 Starting image processing...")
    print("📄 Input file: \(url.path)")
    print(
      "📋 Preset: \(preset.nickname) (\(preset.format.rawValue), \(preset.maxWidth)x\(preset.maxHeight), quality: \(preset.quality))"
    )

    // Create a temporary directory within the app's sandbox
    let tempDir = try fileManager.url(
      for: .itemReplacementDirectory,
      in: .userDomainMask,
      appropriateFor: url,
      create: true
    )
    print("📁 Created temp directory: \(tempDir.path)")

    // Create temporary input/output paths
    let tempInput = tempDir.appendingPathComponent("input-\(UUID().uuidString)")
      .appendingPathExtension(url.pathExtension)
    let tempOutput = tempDir.appendingPathComponent("output-\(UUID().uuidString)")
      .appendingPathExtension(preset.format.fileExtension)
    print("📥 Temp input path: \(tempInput.path)")
    print("📤 Temp output path: \(tempOutput.path)")

    // Copy input file to temp directory
    do {
      try fileManager.copyItem(at: url, to: tempInput)
      print("✅ Copied input file to temp directory")
    } catch {
      print("❌ Failed to copy input file: \(error)")
      throw error
    }

    // Prepare options for the Node script
    let options: [String: Any] = [
      "maxWidth": preset.maxWidth,
      "maxHeight": preset.maxHeight,
      "format": preset.format.rawValue,
      "quality": preset.quality,
    ]
    print("⚙️ Node script options: \(options)")

    let optionsJSON = try JSONSerialization.data(withJSONObject: options)
    let optionsString = String(data: optionsJSON, encoding: .utf8)!

    // Create and configure the Node process
    let process = Process()
    process.executableURL = URL(fileURLWithPath: nodeBinaryPath)
    print("🔧 Node binary path: \(nodeBinaryPath)")
    print("📜 Node script path: \(nodeScriptPath)")

    // Set up environment variables
    var env = ProcessInfo.processInfo.environment
    env["NODE_PATH"] = nodeModulesPath
    process.environment = env
    print("🌍 NODE_PATH set to: \(nodeModulesPath)")

    process.arguments = [
      nodeScriptPath,
      tempInput.path,
      tempOutput.path,
      optionsString,
    ]
    print("🎯 Process arguments: \(process.arguments ?? [])")

    // Set up pipes for output
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      print("▶️ Starting Node process...")
      try process.run()
      process.waitUntilExit()

      let status = process.terminationStatus
      print("⏹️ Process terminated with status: \(status)")

      if status != 0 {
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

        print("📤 Process output: \(String(data: outputData, encoding: .utf8) ?? "none")")
        print("❌ Process error: \(String(data: errorData, encoding: .utf8) ?? "none")")

        if let errorString = String(data: errorData, encoding: .utf8) {
          throw ImageProcessingError.nodejsError(errorString)
        } else {
          throw ImageProcessingError.nodejsError("Unknown error")
        }
      }

      // Create final output URL
      let finalOutput = (outputDirectory ?? url.deletingLastPathComponent())
        .appendingPathComponent(url.deletingPathExtension().lastPathComponent)
        .appendingPathExtension(preset.format.fileExtension)
      print("📝 Final output path: \(finalOutput.path)")

      // Check if output file exists
      print("🔍 Checking if output file exists at: \(tempOutput.path)")
      if fileManager.fileExists(atPath: tempOutput.path) {
        print("✅ Output file exists")
      } else {
        print("❌ Output file not found!")
        throw ImageProcessingError.failedToSaveImage
      }

      // Move the processed file to final location
      if fileManager.fileExists(atPath: finalOutput.path) {
        print("🗑️ Removing existing file at destination")
        try fileManager.removeItem(at: finalOutput)
      }

      do {
        try fileManager.moveItem(at: tempOutput, to: finalOutput)
        print("✅ Successfully moved output file to final location")
      } catch {
        print("❌ Failed to move output file: \(error)")
        throw error
      }

      // Clean up temp directory
      try? fileManager.removeItem(at: tempDir)
      print("🧹 Cleaned up temporary directory")

      print("✅ Image processing completed successfully")
      return finalOutput
    } catch {
      print("❌ Process failed with error: \(error)")
      // Clean up temp directory on error
      try? fileManager.removeItem(at: tempDir)
      print("🧹 Cleaned up temporary directory after error")
      throw ImageProcessingError.nodejsError(error.localizedDescription)
    }
  }
}

enum ImageProcessingError: LocalizedError {
  case failedToSaveImage
  case nodejsError(String)

  var errorDescription: String? {
    switch self {
    case .failedToSaveImage:
      return "Failed to save the image"
    case .nodejsError(let message):
      return "Node.js error: \(message)"
    }
  }
}

// MARK: - Drag and Drop
extension AppViewModel {
  func validateDrop(urls: [URL]) -> Bool {
    // Accept only image files
    let validExtensions = ["jpg", "jpeg", "png", "avif", "webp", "tiff"]
    return urls.allSatisfy { url in
      validExtensions.contains(url.pathExtension.lowercased())
    }
  }
}
