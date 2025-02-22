import CoreImage
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
    case avif
    case png
    case jpeg
    case webp
    case tiff

    var fileExtension: String {
      rawValue
    }

    var compressionQualityEnabled: Bool {
      switch self {
      case .png, .tiff: return false
      case .avif, .jpeg, .webp: return true
      }
    }
  }

  enum OutputLocation: LocalizedStringResource, Codable, CaseIterable {
    case temporary = "Temporary Only"
    case sourceDirectory = "Same as Source"
    case custom = "Custom Location"
  }

  init(
    nickname: String = "New Preset",
    maxWidth: Int = 1920,
    maxHeight: Int = 1080,
    format: ImageFormat = .jpeg,
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
