import Foundation

struct ConversionTask: Identifiable {
  let id: UUID = UUID()
  let sourceURL: URL
  let preset: ConversionPreset
  var status: Status = .pending
  var progress: Double = 0
  var error: Error?

  enum Status {
    case pending
    case converting
    case completed
    case failed
  }
}

struct ConversionBatch: Identifiable {
  let id: UUID = UUID()
  var tasks: [ConversionTask]
  var startTime: Date?
  var endTime: Date?
  var outputDirectory: URL?

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
}
