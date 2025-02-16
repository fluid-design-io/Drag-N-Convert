import SwiftUI

struct PresetEditorView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var viewModel: AppViewModel

  @State private var nickname: String
  @State private var maxWidth: String
  @State private var maxHeight: String
  @State private var format: ConversionPreset.ImageFormat
  @State private var quality: Double
  @State private var outputPath: String
  @State private var deleteOriginal: Bool

  private let existingPreset: ConversionPreset?

  init(preset: ConversionPreset?) {
    self.existingPreset = preset

    _nickname = State(initialValue: preset?.nickname ?? "New Preset")
    _maxWidth = State(initialValue: String(preset?.maxWidth ?? 1920))
    _maxHeight = State(initialValue: String(preset?.maxHeight ?? 1080))
    _format = State(initialValue: preset?.format ?? .png)
    _quality = State(initialValue: Double(preset?.quality ?? 85))
    _outputPath = State(initialValue: preset?.outputPath ?? "")
    _deleteOriginal = State(initialValue: preset?.deleteOriginal ?? false)
  }

  var body: some View {
    VStack(spacing: 16) {
      Text(existingPreset == nil ? "New Preset" : "Edit Preset")
        .font(.headline)

      Form {
        TextField("Nickname", text: $nickname)

        HStack {
          TextField("Max Width", text: $maxWidth)
          Text("×")
          TextField("Max Height", text: $maxHeight)
        }

        Picker("Format", selection: $format) {
          ForEach(ConversionPreset.ImageFormat.allCases, id: \.self) { format in
            Text(format.rawValue.uppercased())
              .tag(format)
          }
        }

        HStack {
          Text("Quality: \(Int(quality))")
          Slider(value: $quality, in: 1...100)
        }

        HStack {
          TextField("Output Path (Optional)", text: $outputPath)
          Button("Browse") {
            selectOutputPath()
          }
        }

        Toggle("Delete Original Files", isOn: $deleteOriginal)
      }
      .formStyle(.columns)

      HStack {
        Button("Cancel") {
          dismiss()
        }
        .keyboardShortcut(.escape)

        Button("Save") {
          savePreset()
        }
        .keyboardShortcut(.return)
        .buttonStyle(.borderedProminent)
      }
    }
    .padding()
    .frame(width: 400)
  }

  private func selectOutputPath() {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false

    if panel.runModal() == .OK {
      outputPath = panel.url?.path ?? ""
    }
  }

  private func savePreset() {
    guard let width = Int(maxWidth),
      let height = Int(maxHeight),
      width > 0 && height > 0
    else {
      return
    }

    let preset = ConversionPreset(
      nickname: nickname,
      maxWidth: width,
      maxHeight: height,
      format: format,
      quality: Int(quality),
      outputPath: outputPath.isEmpty ? nil : outputPath,
      deleteOriginal: deleteOriginal
    )

    if let existingPreset {
      var updatedPreset = preset
      updatedPreset.id = existingPreset.id
      viewModel.updatePreset(updatedPreset)
    } else {
      viewModel.addPreset(preset)
    }

    dismiss()
  }
}
