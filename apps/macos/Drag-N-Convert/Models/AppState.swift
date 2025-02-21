import Foundation

struct AppState: Codable {
  var presets: [ConversionPreset]
  var lastUsedPresetId: UUID?
  var defaultOutputPath: String?
  var autoCloseAfterConversion: Bool
  var autoCloseDelay: TimeInterval

  var lastUsedPreset: ConversionPreset {
    if let id = lastUsedPresetId,
      let preset = presets.first(where: { $0.id == id })
    {
      return preset
    }
    return presets.first ?? ConversionPreset()
  }

  init(
    presets: [ConversionPreset] = [],
    lastUsedPresetId: UUID? = nil,
    defaultOutputPath: String? = nil,
    autoCloseAfterConversion: Bool = false,
    autoCloseDelay: TimeInterval = 5.0
  ) {
    self.presets = presets
    self.lastUsedPresetId = lastUsedPresetId
    self.defaultOutputPath = defaultOutputPath
    self.autoCloseAfterConversion = autoCloseAfterConversion
    self.autoCloseDelay = autoCloseDelay
  }
}
