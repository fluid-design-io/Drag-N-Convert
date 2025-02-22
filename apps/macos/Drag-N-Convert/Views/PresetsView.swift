import SwiftUI

struct PresetsView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @State private var selectedPresets: Set<ConversionPreset> = []

  private func addPreset() {
    withAnimation {
      let newPreset = ConversionPreset(nickname: "Untitled Preset")
      viewModel.addPreset(newPreset)
      selectedPresets = [newPreset]
    }
  }

  private func duplicatePreset(_ preset: ConversionPreset) {
    withAnimation {
      var newPreset = preset
      newPreset.id = UUID()
      newPreset.nickname += " Copy"
      viewModel.addPreset(newPreset)
      selectedPresets = [newPreset]
    }
  }

  private func deletePreset(_ preset: ConversionPreset) {
    withAnimation {
      // select the previous preset (if it exists)
      if let index = viewModel.state.presets.firstIndex(of: preset) {
        if index > 0 {
          selectedPresets = [viewModel.state.presets[index - 1]]
        } else {
          selectedPresets = []
        }
      } else {
        selectedPresets = []
      }
      viewModel.deletePreset(preset)
    }
  }

  private func savePreset(_ preset: ConversionPreset) {
    withAnimation {
      viewModel.updatePreset(preset)
      // Update selection to reference the new preset instance
      if let updatedPreset = viewModel.state.presets.first(where: { $0.id == preset.id }) {
        selectedPresets = [updatedPreset]
      }
    }
  }

  var body: some View {
    NavigationSplitView {
      List(selection: $selectedPresets) {
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
            if selectedPresets.count <= 1 {
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
            }

            Button(
              role: .destructive,
              action: {
                if selectedPresets.count > 1 {
                  // Delete all selected presets
                  withAnimation {
                    selectedPresets.forEach { viewModel.deletePreset($0) }
                    selectedPresets = []
                  }
                } else {
                  deletePreset(preset)
                }
              }
            ) {
              Label(
                selectedPresets.count > 1
                  ? "Delete \(selectedPresets.count) Presets" : "Delete Preset",
                systemImage: "trash"
              )
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
      if let preset = selectedPresets.first {
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
  @State private var outputLocation: ConversionPreset.OutputLocation
  @State private var customOutputPath: String?
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
      || outputLocation != preset.outputLocation
      || customOutputPath != preset.customOutputPath
      || deleteOriginal != preset.deleteOriginal

    return isValid && isModified
  }

  private func updatePreset() {
    guard isValid else { return }

    var preset = ConversionPreset(
      nickname: nickname,
      maxWidth: Int(width) ?? 1920,
      maxHeight: Int(height) ?? 1080,
      format: format,
      quality: Int(quality),
      outputLocation: outputLocation,
      customOutputPath: outputLocation == .custom ? customOutputPath : nil,
      deleteOriginal: deleteOriginal
    )
    preset.id = presetId
    onSave(preset)
  }

  init(
    preset: ConversionPreset,
    onSave: @escaping (ConversionPreset) -> Void,
    onDelete: @escaping () -> Void
  ) {
    self._nickname = State(initialValue: preset.nickname)
    self._format = State(initialValue: preset.format)
    self._width = State(initialValue: String(preset.maxWidth))
    self._height = State(initialValue: String(preset.maxHeight))
    self._quality = State(initialValue: Double(preset.quality))
    self._outputLocation = State(initialValue: preset.outputLocation)
    self._customOutputPath = State(initialValue: preset.customOutputPath)
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
          .onChange(of: nickname) { _ in updatePreset() }

        Picker("Format", selection: $format) {
          ForEach(ConversionPreset.ImageFormat.allCases, id: \.self) { format in
            Text(format.rawValue.uppercased()).tag(format)
          }
        }
        .onChange(of: format) { _ in updatePreset() }
      }

      Section {
        VStack(alignment: .leading) {
          HStack {
            TextField("Width", text: $width)
              .textFieldStyle(.roundedBorder)
              .onChange(of: width) { _ in updatePreset() }
            Text("×")
            TextField("Height", text: $height)
              .textFieldStyle(.roundedBorder)
              .onChange(of: height) { _ in updatePreset() }
          }
          Text("The image's maximum width and height.")
            .foregroundStyle(.secondary)
        }
      }

      Section {
        HStack {
          Text("Quality: \(Int(quality))%")
          Slider(value: $quality, in: 0...100)
            .onChange(of: quality) { _ in updatePreset() }
        }
      }

      Section {
        VStack(alignment: .leading) {
          Picker("Save converted files in:", selection: $outputLocation) {
            ForEach(ConversionPreset.OutputLocation.allCases, id: \.self) { location in
              Text(location.rawValue).tag(location)
            }
          }
          .onChange(of: outputLocation) { _ in updatePreset() }

          if outputLocation == .custom {
            HStack {
              if let path = customOutputPath {
                Text(path)
                  .truncationMode(.middle)
                  .lineLimit(1)
                  .foregroundStyle(.secondary)
                Spacer()
                Button(role: .destructive) {
                  customOutputPath = nil
                } label: {
                  Image(systemName: "trash")
                    .foregroundStyle(Color.red)
                }
              }

              Button("Choose...") {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                panel.allowsMultipleSelection = false

                if panel.runModal() == .OK {
                  customOutputPath = panel.url?.path
                }
              }
            }
          }

          switch outputLocation {
          case .temporary:
            Text("Files will only be available in the conversion window")
              .foregroundStyle(.secondary)
          case .sourceDirectory:
            Text("Files will be saved alongside the original images")
              .foregroundStyle(.secondary)
          case .custom:
            if customOutputPath == nil {
              Text("Choose a custom output location")
                .foregroundStyle(.secondary)
            }
          }
        }
      }

      Section {
        Toggle("Delete original after conversion", isOn: $deleteOriginal)
          .onChange(of: deleteOriginal) { _ in updatePreset() }
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
      }
    }
    .frame(minWidth: 400)
    .navigationTitle("\(nickname)")
  }
}

#Preview {
  PresetsView()
    .environmentObject(AppViewModel.mockWithPresets())
}
