import Foundation

struct ConversionPreset: Identifiable, Codable, Hashable {
  var id: UUID = UUID()
  var nickname: String
  var maxWidth: Int
  var maxHeight: Int
  var format: ImageFormat
  var quality: Int
  var outputPath: String?
  var deleteOriginal: Bool

  enum ImageFormat: String, Codable, CaseIterable {
    case avif
    case png
    case webp
    case jpeg
  }

  init(
    nickname: String = "New Preset",
    maxWidth: Int = 1920,
    maxHeight: Int = 1080,
    format: ImageFormat = .png,
    quality: Int = 85,
    outputPath: String? = nil,
    deleteOriginal: Bool = false
  ) {
    self.nickname = nickname
    self.maxWidth = maxWidth
    self.maxHeight = maxHeight
    self.format = format
    self.quality = quality
    self.outputPath = outputPath
    self.deleteOriginal = deleteOriginal
  }
}
