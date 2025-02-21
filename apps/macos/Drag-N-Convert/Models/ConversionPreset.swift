import Foundation

struct ConversionPreset: Identifiable, Codable, Hashable {
  var id: UUID = UUID()
  var nickname: String
  var maxWidth: Int
  var maxHeight: Int
  var format: ImageFormat
  var quality: Int
  var outputLocation: OutputLocation = .sourceDirectory
  var customOutputPath: String?  // Only used when outputLocation is .custom
  var deleteOriginal: Bool

  enum ImageFormat: String, Codable, CaseIterable {
    case heif
    case png
    case webp
    case jpeg
  }

  enum OutputLocation: String, Codable, CaseIterable {
    case temporary = "Temporary Only"
    case sourceDirectory = "Same as Source"
    case custom = "Custom Location"
  }

  init(
    nickname: String = "New Preset",
    maxWidth: Int = 1920,
    maxHeight: Int = 1080,
    format: ImageFormat = .png,
    quality: Int = 85,
    outputLocation: OutputLocation = .sourceDirectory,
    customOutputPath: String? = nil,
    deleteOriginal: Bool = false
  ) {
    self.nickname = nickname
    self.maxWidth = maxWidth
    self.maxHeight = maxHeight
    self.format = format
    self.quality = quality
    self.outputLocation = outputLocation
    self.customOutputPath = customOutputPath
    self.deleteOriginal = deleteOriginal
  }
}
