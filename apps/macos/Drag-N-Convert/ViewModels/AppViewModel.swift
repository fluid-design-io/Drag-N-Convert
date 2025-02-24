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
      quality: 90,
      outputLocation: .temporary
    ),
    ConversionPreset(
      nickname: "HD WebP",
      maxWidth: 1920,
      maxHeight: 1080,
      format: .webp,
      quality: 85,
      outputLocation: .temporary
    ),
    ConversionPreset(
      nickname: "Mobile JPEG",
      maxWidth: 1280,
      maxHeight: 720,
      format: .jpeg,
      quality: 80,
      outputLocation: .temporary
    ),
    ConversionPreset(
      nickname: "Mobile AVIF",
      maxWidth: 1280,
      maxHeight: 720,
      format: .avif,
      quality: 80,
      outputLocation: .temporary
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

      // Process tasks concurrently
      await withTaskGroup(of: (Int, Result<URL, Error>).self) { group in
        for (index, task) in updatedBatch.tasks.enumerated() {
          group.addTask {
            var currentTask = task
            currentTask.status = .converting
            let capturedTask = currentTask  // Create an immutable copy

            // Update UI for task start
            await MainActor.run {
              updatedBatch.tasks[index] = capturedTask
              self.currentBatch = updatedBatch
            }

            do {
              let outputURL = try await self.imageProcessor.processImage(
                at: task.sourceURL,
                preset: task.preset,
                outputDirectory: batch.outputDirectory ?? batch.tempDirectory
              )
              return (index, .success(outputURL))
            } catch {
              return (index, .failure(error))
            }
          }
        }

        // Handle results as they complete
        for await (index, result) in group {
          var task = updatedBatch.tasks[index]

          switch result {
          case .success(let outputURL):
            task.outputURL = outputURL
            task.status = .completed

            // Calculate file sizes in Swift
            task.inputSize = ConversionTask.getFileSize(for: task.sourceURL)
            task.outputSize = ConversionTask.getFileSize(for: outputURL)
            task.compressionRatio = task.reductionPercentage

            print("🔄 Updated main batch task with file sizes:")
            print("  Input size: \(task.inputSize.formattedFileSize)")
            print("  Output size: \(task.outputSize.formattedFileSize)")
            print("  Reduction: \(task.reductionPercentage)%")

            if task.preset.deleteOriginal {
              try? FileManager.default.removeItem(at: task.sourceURL)
            }

          case .failure(let error):
            task.status = .failed
            task.error = error
          }

          task.progress = 1.0
          updatedBatch.tasks[index] = task
          await MainActor.run {
            self.currentBatch = updatedBatch
          }
        }
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

  func processBatch(_ tasks: [ConversionTask], outputDirectory: URL?) async throws -> [URL] {
    // Create a temporary batch directory
    let batchDir = try fileManager.url(
      for: .itemReplacementDirectory,
      in: .userDomainMask,
      appropriateFor: tasks.first?.sourceURL,
      create: true
    )
    defer { try? fileManager.removeItem(at: batchDir) }

    print("📁 Created batch directory: \(batchDir.path)")

    // Create batch configuration
    let batchTasks = try tasks.map { task -> [String: Any] in
      let tempInput = batchDir.appendingPathComponent("input-\(UUID().uuidString)")
        .appendingPathExtension(task.sourceURL.pathExtension)
      let tempOutput = batchDir.appendingPathComponent("output-\(UUID().uuidString)")
        .appendingPathExtension(task.preset.format.fileExtension)

      // Copy input file
      try fileManager.copyItem(at: task.sourceURL, to: tempInput)

      return [
        "inputPath": tempInput.path,
        "outputPath": tempOutput.path,
        "options": [
          "maxWidth": task.preset.maxWidth,
          "maxHeight": task.preset.maxHeight,
          "format": task.preset.format.rawValue,
          "quality": task.preset.quality,
        ],
      ]
    }

    // Write batch configuration
    let batchConfig = ["tasks": batchTasks]
    let configData = try JSONSerialization.data(
      withJSONObject: batchConfig, options: .prettyPrinted)
    try configData.write(to: batchDir.appendingPathComponent("batch-config.json"))

    // Create and configure the Node process
    let process = Process()
    process.executableURL = URL(fileURLWithPath: nodeBinaryPath)
    process.arguments = [nodeScriptPath, batchDir.path]

    var env = ProcessInfo.processInfo.environment
    env["NODE_PATH"] = nodeModulesPath
    env["SHARP_CONCURRENCY"] = String(ProcessInfo.processInfo.processorCount)
    process.environment = env

    // Set up pipes for output
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    // Run the process
    print("▶️ Starting batch processing...")
    try process.run()
    process.waitUntilExit()

    // Check for errors
    if process.terminationStatus != 0 {
      let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
      if let errorString = String(data: errorData, encoding: .utf8) {
        throw ImageProcessingError.nodejsError(errorString)
      }
      throw ImageProcessingError.nodejsError("Unknown error")
    }

    // Read results
    let resultsPath = batchDir.appendingPathComponent("batch-results.json")
    let resultsData = try Data(contentsOf: resultsPath)
    let results = try JSONSerialization.jsonObject(with: resultsData) as! [[String: Any]]

    // Process results and move files to final location
    var updatedTasks = tasks  // Create mutable copy
    return try results.enumerated().map { index, result in
      let task = updatedTasks[index]

      guard result["success"] as? Bool == true,
        let outputPath = result["outputPath"] as? String
      else {
        print("❌ Error processing \(task.sourceURL.lastPathComponent):")
        let error = result["error"] as? String ?? "Unknown error"
        throw ImageProcessingError.nodejsError(error)
      }

      let tempOutput = URL(fileURLWithPath: outputPath)
      let finalOutput = (outputDirectory ?? task.sourceURL.deletingLastPathComponent())
        .appendingPathComponent(task.sourceURL.deletingPathExtension().lastPathComponent)
        .appendingPathExtension(task.preset.format.fileExtension)

      if fileManager.fileExists(atPath: finalOutput.path) {
        try fileManager.removeItem(at: finalOutput)
      }

      try fileManager.moveItem(at: tempOutput, to: finalOutput)

      // Delete original if requested
      if task.preset.deleteOriginal {
        try? fileManager.removeItem(at: task.sourceURL)
      }

      updatedTasks[index] = task

      return finalOutput
    }
  }

  func processImage(at url: URL, preset: ConversionPreset, outputDirectory: URL?) async throws
    -> URL
  {
    let task = ConversionTask(sourceURL: url, preset: preset)
    let results = try await processBatch([task], outputDirectory: outputDirectory)
    return results[0]
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
