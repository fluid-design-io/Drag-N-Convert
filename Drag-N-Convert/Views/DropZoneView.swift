import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
  @EnvironmentObject private var viewModel: AppViewModel

  var body: some View {
    VStack(spacing: 6) {
      if let batch = viewModel.currentBatch {
        ConversionProgressView(batch: batch)
          .transition(.move(edge: .top).combined(with: .opacity))
      } else {
        LastUsedPresetView()
          .transition(.move(edge: .bottom).combined(with: .opacity))
        PresetGridView()
          .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .padding(6)
    .frame(width: 420)
    .background(.regularMaterial)
    .clipShape(.rect(cornerRadius: 36, style: .continuous))
  }
}

struct LastUsedPresetView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @State private var hoveredPresetId: UUID?

  var body: some View {
    ZStack(alignment: .topTrailing) {
      PresetDropZoneView(
        preset: viewModel.state.lastUsedPreset,
        isHovered: hoveredPresetId == viewModel.state.lastUsedPreset.id
      )
      .onDrop(
        of: [.fileURL],
        delegate: DragOverDelegate(
          preset: viewModel.state.lastUsedPreset,
          viewModel: viewModel,
          hoveredPresetId: $hoveredPresetId
        ))
      Text("Last Used Preset")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding(20)
    }
  }
}

struct PresetGridView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @State private var hoveredPresetId: UUID?

  var body: some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132))], spacing: 6) {
      ForEach(viewModel.state.presets) { preset in
        PresetDropZoneView(preset: preset, isHovered: hoveredPresetId == preset.id)
          .onDrop(
            of: [.fileURL],
            delegate: DragOverDelegate(
              preset: preset,
              viewModel: viewModel,
              hoveredPresetId: $hoveredPresetId
            ))
      }
    }
  }

  private func handleDrop(_ preset: ConversionPreset) {
    viewModel.handleFilesDropped(viewModel.draggedFileURLs, preset: preset)
  }
}

// MARK: - Drag Over Delegate
// Sets the dragged over preset id when hovering over a preset
struct DragOverDelegate: DropDelegate {
  let preset: ConversionPreset
  let viewModel: AppViewModel
  @Binding var hoveredPresetId: UUID?

  func dropEntered(info: DropInfo) {
    if hoveredPresetId != preset.id {
      hoveredPresetId = preset.id
    }
  }

  func dropExited(info: DropInfo) {
    if hoveredPresetId == preset.id {
      hoveredPresetId = nil
    }
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    return DropProposal(operation: .move)
  }

  func performDrop(info: DropInfo) -> Bool {
    viewModel.handleFilesDropped(viewModel.draggedFileURLs, preset: preset)
    return true
  }
}

#Preview("Drop Zone - Empty") {
  DropZoneView()
    .environmentObject(AppViewModel.mockEmpty())
}

#Preview("Drop Zone - Converting") {
  DropZoneView()
    .environmentObject(AppViewModel.mockConverting())
}

#Preview("Drop Zone - With Presets") {
  DropZoneView()
    .environmentObject(AppViewModel.mockWithPresets())
}
