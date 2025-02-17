import SwiftUI

struct PresetsView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @State private var selectedPreset: ConversionPreset?

  var body: some View {
    NavigationSplitView {
      List(selection: $selectedPreset) {
        ForEach(viewModel.state.presets) { preset in
          NavigationLink(value: preset) {
            VStack(alignment: .leading) {
              Text(preset.nickname)
                .font(.headline)
              HStack {
                Text(preset.format.rawValue.uppercased())
                Text("•")
                Text("\(preset.maxWidth)×\(preset.maxHeight)")
                Text("•")
                Text("\(preset.quality)%")
              }
              .font(.caption)
              .foregroundStyle(.secondary)
            }
          }
          .tag(preset)
        }
        .onDelete(perform: viewModel.deletePresetAtIndexSet)
        .onMove(perform: viewModel.movePresets)

      }

      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            withAnimation {
              let newPreset = ConversionPreset(nickname: "Untitled Preset")
              viewModel.addPreset(newPreset)
              selectedPreset = newPreset
            }
          } label: {
            Label("Add Preset", systemImage: "plus")
          }
        }
      }
      .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
      .navigationTitle("Presets")
    } detail: {
      if let preset = selectedPreset {
        PresetFormView(
          preset: preset,
          onSave: { updatedPreset in
            withAnimation {
              viewModel.updatePreset(updatedPreset)
              selectedPreset = updatedPreset
            }
          }
        )
        .id(preset.id)
        .toolbar {
          ToolbarItem {
            Button(role: .destructive) {
              withAnimation {
                // select the previous preset (if it exists)
                if let index = viewModel.state.presets.firstIndex(of: preset) {
                  selectedPreset = viewModel.state.presets[index - 1]
                } else {
                  selectedPreset = nil
                }
                viewModel.deletePreset(preset)
              }
            } label: {
              Label("Delete Preset", systemImage: "trash")
            }
          }
        }
      } else {
        ContentUnavailableView(
          "No Preset Selected",
          systemImage: "slider.horizontal.3",
          description: Text("Select a preset to edit or create a new one.")
        )
      }
    }
  }
}

struct PresetFormView: View {
  @State private var nickname: String
  @State private var format: ConversionPreset.ImageFormat
  @State private var width: String
  @State private var height: String
  @State private var quality: Double
  @State private var outputPath: String?
  @State private var deleteOriginal: Bool
  private let presetId: UUID

  let onSave: (ConversionPreset) -> Void

  private var isValid: Bool {
    !nickname.isEmpty && Int(width) != nil && Int(height) != nil && quality >= 0 && quality <= 100
  }

  private func savePreset() -> ConversionPreset {
    var preset = ConversionPreset(
      nickname: nickname,
      maxWidth: Int(width) ?? 1920,
      maxHeight: Int(height) ?? 1080,
      format: format,
      quality: Int(quality),
      outputPath: outputPath,
      deleteOriginal: deleteOriginal
    )
    preset.id = presetId
    return preset
  }

  init(preset: ConversionPreset, onSave: @escaping (ConversionPreset) -> Void) {
    self._nickname = State(initialValue: preset.nickname)
    self._format = State(initialValue: preset.format)
    self._width = State(initialValue: String(preset.maxWidth))
    self._height = State(initialValue: String(preset.maxHeight))
    self._quality = State(initialValue: Double(preset.quality))
    self._outputPath = State(initialValue: preset.outputPath)
    self._deleteOriginal = State(initialValue: preset.deleteOriginal)
    self.presetId = preset.id
    self.onSave = onSave
  }

  var body: some View {
    Form {
      TextField("Nickname", text: $nickname)
        .textFieldStyle(.roundedBorder)

      Picker("Format", selection: $format) {
        ForEach(ConversionPreset.ImageFormat.allCases, id: \.self) { format in
          Text(format.rawValue.uppercased()).tag(format)
        }
      }

      HStack {
        TextField("Width", text: $width)
          .textFieldStyle(.roundedBorder)
        Text("×")
        TextField("Height", text: $height)
          .textFieldStyle(.roundedBorder)
      }

      HStack {
        Text("Quality: \(Int(quality))%")
        Slider(value: $quality, in: 0...100)
      }

      VStack(alignment: .leading) {
        HStack {
          Text("Output folder:")
          Spacer()
          Button("Choose...") {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.allowsMultipleSelection = false

            if panel.runModal() == .OK {
              outputPath = panel.url?.path
            }
          }
        }

        if let path = outputPath {
          Text(path)
            .truncationMode(.middle)
            .lineLimit(1)
            .foregroundStyle(.secondary)
        }
      }

      Toggle("Delete original after conversion", isOn: $deleteOriginal)

      Button("Save Changes") {
        let preset = savePreset()
        onSave(preset)
      }
      .buttonStyle(.borderedProminent)
      .disabled(!isValid)
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .formStyle(.grouped)
    .frame(minWidth: 400)
    .navigationTitle("\(nickname)")
    .onSubmit {
      if !isValid {
        return
      }
      let preset = savePreset()
      onSave(preset)
    }
  }
}

#Preview {
  PresetsView()
    .environmentObject(AppViewModel.mockWithPresets())
}
