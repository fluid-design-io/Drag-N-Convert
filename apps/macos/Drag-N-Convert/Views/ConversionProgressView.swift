import AppKit
import SwiftUI

struct ConversionProgressView: View {
  let batch: ConversionBatch

  @EnvironmentObject private var viewModel: AppViewModel

  var body: some View {
    VStack(spacing: 16) {
      switch batch.status {
      case .completed:
        CompletedFilesView(batch: batch)
          .transition(.move(edge: .top).combined(with: .opacity))

      case .failed:
        VStack(spacing: 8) {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 32))
            .foregroundStyle(.red)
            .transition(.symbolEffect(.appear))

          Text("Conversion Failed")
            .font(.headline)

          Text(batch.error?.localizedDescription ?? "Unknown error")
            .font(.subheadline)
            .foregroundStyle(.secondary)

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
    .frame(minWidth: 420, minHeight: 300)
    .animation(.snappy, value: batch.status)
  }
}

#Preview("Conversion Progress") {
  Group {
    // Pending state
    ConversionProgressView(
      batch: ConversionBatch(
        tasks: [
          ConversionTask(
            sourceURL: URL(fileURLWithPath: "/test.jpg"),
            preset: ConversionPreset()
          )
        ]
      )
    )

    // Converting state
    ConversionProgressView(
      batch: AppViewModel.mockConverting().currentBatch!
    )

    // Completed state
    ConversionProgressView(
      batch: ConversionBatch(
        tasks: [
          ConversionTask(
            sourceURL: URL(fileURLWithPath: "/test.jpg"),
            preset: ConversionPreset(),
            status: .completed,
            progress: 1.0
          )
        ],
        startTime: Date().addingTimeInterval(-5),
        endTime: Date(),
        outputDirectory: FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
      )
    )

    // Failed state
    ConversionProgressView(
      batch: ConversionBatch(
        tasks: [
          ConversionTask(
            sourceURL: URL(fileURLWithPath: "/test.jpg"),
            preset: ConversionPreset(),
            status: .failed,
            progress: 0.5,
            error: NSError(domain: "TestError", code: -1)
          )
        ],
        startTime: Date().addingTimeInterval(-3),
        endTime: Date()
      )
    )
  }
  .environmentObject(AppViewModel.mockEmpty())
  .frame(width: 420)
  .padding()
  .background(.background)
}
