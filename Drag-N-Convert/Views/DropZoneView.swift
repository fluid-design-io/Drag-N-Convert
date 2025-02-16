import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
  @EnvironmentObject private var viewModel: AppViewModel

  var body: some View {
    VStack(spacing: 6) {
      if let batch = viewModel.currentBatch {
        ConversionProgressView(batch: batch)
      } else {
        LastUsedPresetView()
        PresetGridView()
      }
    }
    .padding(6)
    .frame(width: 350)
    .background {
      RoundedRectangle(cornerRadius: 32, style: .continuous)
        .fill(.ultraThinMaterial)
    }
  }
}

struct LastUsedPresetView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @State private var hoveredPresetId: UUID?

  var body: some View {
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
  }
}

struct PresetGridView: View {
  @EnvironmentObject private var viewModel: AppViewModel
  @State private var hoveredPresetId: UUID?

  var body: some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 6) {
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

struct PresetDropZoneView: View {
  let preset: ConversionPreset
  let isHovered: Bool

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: "arrow.down.circle")
        .font(.system(size: 24))

      Text(preset.nickname)
        .font(.subheadline)
        .lineLimit(1)

      Text("\(preset.format.rawValue.uppercased())")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 16)
    .frame(minWidth: 100, maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(isHovered ? .blue.opacity(0.1) : .secondary.opacity(0.1))
    }
    .overlay {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .strokeBorder(isHovered ? .blue : .clear, lineWidth: 2)
    }
    .onChange(of: isHovered) { oldValue, newValue in
      if newValue {
        NSHapticFeedbackManager.defaultPerformer.perform(
          .alignment, performanceTime: .default)
      }
    }
  }
}

struct ConversionProgressView: View {
  let batch: ConversionBatch
  @EnvironmentObject private var viewModel: AppViewModel

  var body: some View {
    VStack(spacing: 16) {
      switch batch.status {
      case .completed:
        VStack(spacing: 8) {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 32))
            .foregroundStyle(.green)

          Text("Conversion Complete")
            .font(.headline)

          if let outputDirectory = batch.outputDirectory {
            Button("Open Folder") {
              NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: outputDirectory.path)
            }
            .buttonStyle(.borderedProminent)
          }
        }

      case .failed:
        VStack(spacing: 8) {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 32))
            .foregroundStyle(.red)

          Text("Conversion Failed")
            .font(.headline)

          Button("Try Again") {
            viewModel.startConversion()
          }
          .buttonStyle(.borderedProminent)
        }

      case .converting:
        VStack(spacing: 8) {
          ProgressView(value: batch.progress) {
            Text("\(Int(batch.progress * 100))%")
              .font(.caption)
              .foregroundStyle(.secondary)
          }

          Text("Converting \(batch.tasks.count) files...")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

      case .pending:
        ProgressView()
      }
    }
    .padding(.vertical, 32)
    .padding(.horizontal, 6)
  }
}
