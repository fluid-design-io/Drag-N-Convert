import AppKit
import SwiftUI

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
  .frame(width: 350)
  .padding()
  .background(.background)
}
