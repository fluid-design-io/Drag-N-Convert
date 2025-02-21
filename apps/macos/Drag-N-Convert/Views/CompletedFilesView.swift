import SwiftUI

struct CompletedFilesView: View {
  let batch: ConversionBatch
  @EnvironmentObject private var viewModel: AppViewModel

  var body: some View {
    VStack(spacing: 12) {
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

      ScrollView {
        LazyVStack(spacing: 8) {
          ForEach(batch.tasks.filter { $0.status == .completed }) { task in
            DraggableFileRow(task: task)
          }
        }
      }

      Text("Drag files to copy them")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding()
    .frame(minHeight: 200)
  }
}

struct DraggableFileRow: View {
  let task: ConversionTask

  var body: some View {
    HStack {
      Image(systemName: "doc")
      Text(task.outputURL?.lastPathComponent ?? "")
      Spacer()
    }
    .padding(8)
    .background(.quaternary, in: .rect(cornerRadius: 8))
    .draggable(task.outputURL?.path ?? "") {
      Label(task.outputURL?.lastPathComponent ?? "", systemImage: "doc")
    }
  }
}
