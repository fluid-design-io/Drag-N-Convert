import SwiftUI

struct PresetsView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @State private var selectedPreset: ConversionPreset?

  private func addPreset() {
    withAnimation {
      let newPreset = ConversionPreset(nickname: "Untitled Preset")
      viewModel.addPreset(newPreset)
      selectedPreset = newPreset
    }
  }

  private func duplicatePreset(_ preset: ConversionPreset) {
    withAnimation {
      var newPreset = preset
      newPreset.id = UUID()
      newPreset.nickname += " Copy"
      viewModel.addPreset(newPreset)
      selectedPreset = newPreset
    }
  }

  private func deletePreset(_ preset: ConversionPreset) {
    withAnimation {
      // select the previous preset (if it exists)
      if let index = viewModel.state.presets.firstIndex(of: preset) {
        selectedPreset = index > 0 ? viewModel.state.presets[index - 1] : nil
      } else {
        selectedPreset = nil
      }
      viewModel.deletePreset(preset)
    }
  }

  private func savePreset(_ preset: ConversionPreset) {
    withAnimation {
      viewModel.updatePreset(preset)
      // Update selection to reference the new preset instance
      if let updatedPreset = viewModel.state.presets.first(where: { $0.id == preset.id }) {
        selectedPreset = updatedPreset
      }
    }
  }

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
          .contextMenu {
            Button {
              addPreset()
            } label: {
              Label("Add Preset", systemImage: "plus")
            }
            Button {
              duplicatePreset(preset)
            } label: {
              Label("Duplicate Preset", systemImage: "square.on.square")
            }

            Divider()
            Button(
              role: .destructive,
              action: {
                deletePreset(preset)
              }
            ) {
              Label("Delete Preset", systemImage: "trash")
            }
          }
        }
        .onDelete(perform: viewModel.deletePresetAtIndexSet)
        .onMove(perform: viewModel.movePresets)
      }
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: addPreset) {
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
          onSave: savePreset,
          onDelete: { deletePreset(preset) }
        )
        .id(preset.id)
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
  @EnvironmentObject private var viewModel: AppViewModel

  @State private var nickname: String
  @State private var format: ConversionPreset.ImageFormat
  @State private var width: String
  @State private var height: String
  @State private var quality: Double
  @State private var outputPath: String?
  @State private var deleteOriginal: Bool
  private let presetId: UUID
  var onSave: (ConversionPreset) -> Void
  var onDelete: () -> Void

  private var isValid: Bool {
    guard let widthInt = Int(width),
      let heightInt = Int(height)
    else {
      return false
    }

    return !nickname.isEmpty && widthInt > 0 && heightInt > 0 && quality >= 0 && quality <= 100
  }

  // disable the save button if the preset is not valid
  // and user has modified the preset
  private var canSave: Bool {
    guard let preset = viewModel.state.presets.first(where: { $0.id == presetId }),
      let widthInt = Int(width),
      let heightInt = Int(height)
    else {
      return false
    }

    let isModified =
      nickname != preset.nickname || format != preset.format || widthInt != preset.maxWidth
      || heightInt != preset.maxHeight || Int(quality) != preset.quality
      || outputPath != preset.outputPath || deleteOriginal != preset.deleteOriginal

    return isValid && isModified
  }

  private func savePreset() {
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
    onSave(preset)
  }

  init(
    preset: ConversionPreset, onSave: @escaping (ConversionPreset) -> Void,
    onDelete: @escaping () -> Void
  ) {
    self._nickname = State(initialValue: preset.nickname)
    self._format = State(initialValue: preset.format)
    self._width = State(initialValue: String(preset.maxWidth))
    self._height = State(initialValue: String(preset.maxHeight))
    self._quality = State(initialValue: Double(preset.quality))
    self._outputPath = State(initialValue: preset.outputPath)
    self._deleteOriginal = State(initialValue: preset.deleteOriginal)
    self.presetId = preset.id
    self.onSave = onSave
    self.onDelete = onDelete
  }

  var body: some View {
    Form {
      Section {
        TextField("Nickname", text: $nickname)
          .textFieldStyle(.roundedBorder)

        Picker("Format", selection: $format) {
          ForEach(ConversionPreset.ImageFormat.allCases, id: \.self) { format in
            Text(format.rawValue.uppercased()).tag(format)
          }
        }
      }

      Section {
        VStack(alignment: .leading) {
          HStack {
            TextField("Width", text: $width)
              .textFieldStyle(.roundedBorder)
            Text("×")
            TextField("Height", text: $height)
              .textFieldStyle(.roundedBorder)
          }
          Text("The image's maximum width and height.")
            .foregroundStyle(.secondary)
        }
      }

      Section {
        HStack {
          Text("Quality: \(Int(quality))%")
          Slider(value: $quality, in: 0...100)
        }
      }

      Section {
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
            HStack {
              Text(path)
                .truncationMode(.middle)
                .lineLimit(1)
                .foregroundStyle(.secondary)
              Spacer()
              Button(role: .destructive) {
                outputPath = nil
              } label: {
                Image(systemName: "trash")
                  .foregroundStyle(Color.red)
              }
            }
          } else {
            Text("The image will be saved to the current directory.")
              .foregroundStyle(.secondary)
          }
        }
      }

      Section {
        Toggle("Delete original after conversion", isOn: $deleteOriginal)
      }
    }
    .formStyle(.grouped)
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Button(role: .destructive) {
          onDelete()
        } label: {
          Label("Delete Preset", systemImage: "trash")
        }

        RoundedRectangle(cornerRadius: 2)
          .fill(Color.secondary.opacity(0.1))
          .frame(width: 1, height: 16)
          .padding(.horizontal, 8)
        Button("Save Changes") {
          savePreset()
        }
        .disabled(!canSave)
      }
    }
    .frame(minWidth: 400)
    .navigationTitle("\(nickname)")
    .onSubmit {
      if !canSave {
        return
      }
      savePreset()
    }
  }
}

#Preview {
  PresetsView()
    .environmentObject(AppViewModel.mockWithPresets())
}
