import SwiftUI

struct MenuBarView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @State private var isPresetEditorPresented = false

  var body: some View {
    VStack(spacing: 12) {
      Text("Drag-N-Convert")
        .font(.headline)

      Divider()

      VStack(alignment: .leading, spacing: 4) {
        Text("Presets")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        if viewModel.state.presets.isEmpty {
          Text("No presets yet")
            .foregroundStyle(.secondary)
            .italic()
        } else {
          ForEach(viewModel.state.presets) { preset in
            PresetRowView(preset: preset)
          }
        }

        Button("Add Preset") {
          isPresetEditorPresented = true
        }
        .buttonStyle(.borderless)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Divider()

      Button("Quit") {
        NSApplication.shared.terminate(nil)
      }
    }
    .padding()
    .frame(width: 280)
    .sheet(isPresented: $isPresetEditorPresented) {
      PresetEditorView(preset: nil)
    }
  }
}

struct PresetRowView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @State private var isEditing = false
  let preset: ConversionPreset

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(preset.nickname)
          .fontWeight(.medium)

        Text(
          "\(preset.format.rawValue.uppercased()) • \(preset.maxWidth)×\(preset.maxHeight) • Q\(preset.quality)"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
      }

      Spacer()

      Menu {
        Button("Edit") {
          isEditing = true
        }

        Button("Delete", role: .destructive) {
          viewModel.deletePreset(preset)
        }
      } label: {
        Image(systemName: "ellipsis")
          .contentShape(Rectangle())
      }
      .menuStyle(.borderlessButton)
      .fixedSize()
    }
    .padding(.vertical, 4)
    .sheet(isPresented: $isEditing) {
      PresetEditorView(preset: preset)
    }
  }
}
