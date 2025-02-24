import Foundation

struct ConversionTask: Identifiable, Hashable {
  let id = UUID()
  let sourceURL: URL
  let preset: ConversionPreset
  var status: Status = .pending
  var progress: Double = 0.0
  var outputURL: URL?
  var error: Error?
  var inputSize: Int64 = 0
  var outputSize: Int64 = 0
  var compressionRatio: Double = 0

  enum Status: Hashable {
    case pending
    case converting
    case completed
    case failed
  }

  // Helper method to calculate file size
  static func getFileSize(for url: URL) -> Int64 {
    (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
  }

  // Calculate reduction percentage (how much smaller the output is)
  var reductionPercentage: Double {
    guard inputSize > 0 else { return 0 }
    return (1.0 - Double(outputSize) / Double(inputSize)) * 100.0
  }

  var fileSizeInfo: String {
    print("📊 File size debug for \(sourceURL.lastPathComponent):")
    print("  Status: \(status)")
    print("  Input size: \(inputSize)")
    print("  Output size: \(outputSize)")
    print("  Reduction: \(reductionPercentage)%")

    guard status == .completed, inputSize > 0, outputSize > 0 else {
      print("  ❌ Returning empty string due to invalid conditions")
      return ""
    }

      return String(localized:"\(outputSize.formattedFileSize) (\(Int(reductionPercentage))% smaller)" )
  }

  // Implement Equatable
  static func == (lhs: ConversionTask, rhs: ConversionTask) -> Bool {
    lhs.id == rhs.id && lhs.sourceURL == rhs.sourceURL && lhs.preset == rhs.preset
      && lhs.status == rhs.status && lhs.progress == rhs.progress && lhs.outputURL == rhs.outputURL
      && lhs.inputSize == rhs.inputSize && lhs.outputSize == rhs.outputSize
      && lhs.compressionRatio == rhs.compressionRatio
  }

  // Implement Hashable
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(sourceURL)
    hasher.combine(preset)
    hasher.combine(status)
    hasher.combine(progress)
    hasher.combine(outputURL)
    hasher.combine(inputSize)
    hasher.combine(outputSize)
    hasher.combine(compressionRatio)
  }
}

struct ConversionBatch: Identifiable {
  let id: UUID = UUID()
  var tasks: [ConversionTask]
  var startTime: Date?
  var endTime: Date?
  var outputDirectory: URL?
  var tempDirectory: URL?
  var error: Error?
  var progress: Double {
    guard !tasks.isEmpty else { return 0 }
    return tasks.reduce(0) { $0 + $1.progress } / Double(tasks.count)
  }

  var status: ConversionTask.Status {
    if tasks.allSatisfy({ $0.status == .completed }) {
      return .completed
    }
    if tasks.contains(where: { $0.status == .failed }) {
      return .failed
    }
    if tasks.contains(where: { $0.status == .converting }) {
      return .converting
    }
    return .pending
  }

  var hasCompletedTasks: Bool {
    tasks.contains(where: { $0.status == .completed })
  }

  var totalInputSize: Int64 {
    tasks.reduce(0) { $0 + $1.inputSize }
  }

  var totalOutputSize: Int64 {
    tasks.reduce(0) { $0 + $1.outputSize }
  }

  var totalReductionPercentage: Double {
    guard totalInputSize > 0 else { return 0 }
    return (1.0 - Double(totalOutputSize) / Double(totalInputSize)) * 100.0
  }
}

// Helper extension for formatting file sizes
extension Int64 {
  var formattedFileSize: String {
    let byteCountFormatter = ByteCountFormatter()
    byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
    byteCountFormatter.countStyle = .file
    return byteCountFormatter.string(fromByteCount: self)
  }
}
