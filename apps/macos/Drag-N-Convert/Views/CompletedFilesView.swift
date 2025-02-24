import SwiftUI

struct FileSizeStatsBar: View {
  let batch: ConversionBatch
  @State private var animationProgress: CGFloat = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Total Size Reduction")
            .font(.system(.caption, design: .rounded))
        .foregroundStyle(.secondary)

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          // Original size bar (background)
          RoundedRectangle(cornerRadius: 4)
            .fill(.secondary.opacity(0.2))
            .frame(height: 8)

          // Compressed size bar (overlay)
          RoundedRectangle(cornerRadius: 4)
            .fill(.green.opacity(0.8))
            .frame(
              width: max(
                0,
                (1 - CGFloat(batch.totalOutputSize) / CGFloat(batch.totalInputSize))
                  * geometry.size.width * animationProgress
              ),
              height: 8
            )
        }
      }
      .frame(height: 8)

      Text(
        "\(batch.totalInputSize.formattedFileSize) → \(batch.totalOutputSize.formattedFileSize) (\(Int(batch.totalReductionPercentage))% smaller)"
      )
      .font(.system(.caption, design: .rounded))
      .foregroundStyle(.secondary)
    }
    .onAppear {
        withAnimation(.smooth.delay(1)) {
        animationProgress = 1.0
      }
    }
  }
}

struct CompletedFilesView: View {
  let batch: ConversionBatch
  @EnvironmentObject private var viewModel: AppViewModel

  @State private var multiSelection = Set<UUID>()

  var body: some View {
    VStack(spacing: 6) {
      HStack {
        Text("Converted Files")
              .font(.system(.headline, design: .rounded))
        Spacer()
        Button {
          viewModel.dismissFloatingPanel()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, 24)
      .padding(.top, 24)

      if !batch.tasks.filter({ $0.status == .completed }).isEmpty {
        FileSizeStatsBar(batch: batch)
          .padding(.horizontal, 24)
          .padding(.bottom, 8)
      }

      List(batch.tasks.filter { $0.status == .completed }, selection: $multiSelection) { task in
        DraggableFileRow(task: task)
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .onAppear {
        multiSelection = Set<UUID>(batch.tasks.filter { $0.status == .completed }.map { $0.id })
      }

      HStack {
        Text("Drag files to copy them")
              .font(.system(.caption, design: .rounded))
          .foregroundStyle(.secondary)
      }
      .animation(.snappy, value: multiSelection)
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
  }
}

struct DraggableFileRow: View {
  let task: ConversionTask
  let imageUrl: URL

  init(task: ConversionTask) {
    self.task = task
    self.imageUrl = URL(fileURLWithPath: task.outputURL?.path ?? "")
  }

  var preview: some View {
    HStack {
      HStack {
        if let image = NSImage(contentsOf: imageUrl) {
          Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48, height: 48)
        } else {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundStyle(.secondary)
            .frame(width: 48, height: 48)
        }
      }
      .padding(.horizontal, 8)

      VStack(alignment: .leading) {
        Text(task.outputURL?.lastPathComponent ?? "")
          .font(.system(.body, design: .rounded))
        if !task.fileSizeInfo.isEmpty {
          Text(task.fileSizeInfo)
                .font(.system(.caption, design: .rounded))
            .foregroundStyle(.tertiary)
        }
      }
    }
    .padding(.horizontal, 8)
  }

  var body: some View {
    preview
      .draggable(imageUrl) {
        preview
      }
  }
}
