import SwiftUI

struct CompletedFilesView: View {
  let batch: ConversionBatch
  @EnvironmentObject private var viewModel: AppViewModel

  @State private var multiSelection = Set<UUID>()

  var body: some View {
    VStack(spacing: 6) {
      HStack {
        Text("Converted Files")
          .font(.headline)
        Spacer()
        Button {
          viewModel.clearTempFiles()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, 24)
      .padding(.top, 24)

      List(batch.tasks.filter { $0.status == .completed }, selection: $multiSelection) { task in
        DraggableFileRow(task: task)
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)

      HStack {
        Text("Drag files to copy them")
          .font(.caption)
          .foregroundStyle(.secondary)
        Spacer()
        if multiSelection.count < batch.tasks.filter({ $0.status == .completed }).count {
          Button {
            multiSelection = Set<UUID>(batch.tasks.map { $0.id })
          } label: {
            Label("Select All", systemImage: "checkmark.circle")
          }
          .buttonStyle(.plain)
        } else {
          Button {
            multiSelection = Set<UUID>()
          } label: {
            Label("Deselect All", systemImage: "xmark.circle")
          }
          .buttonStyle(.plain)
        }
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
      Image(nsImage: NSImage(contentsOf: imageUrl)!)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    .padding(8)
  }

  var body: some View {
    HStack {
      preview
      Text(task.outputURL?.lastPathComponent ?? "")
      Spacer()
    }
    .draggable(imageUrl) {
      preview
    }
  }
}
