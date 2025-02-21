import AppKit
import Combine
import SwiftUI

@MainActor
final class WindowManager: ObservableObject {
  @Published var isDropZoneVisible = false
  private let dragMonitor: DragMonitor
  private var viewModel: AppViewModel
  private var cancellables = Set<AnyCancellable>()

  var openWindow: ((String) -> Void)?
  var dismissWindow: ((String) -> Void)?

  init(viewModel: AppViewModel) {
    print("🏗️ Initializing WindowManager")
    self.viewModel = viewModel
    self.dragMonitor = DragMonitor()
    setupDragMonitor()
    setupConversionBatchHandler()
  }

  private func setupDragMonitor() {
    Task {
      for await isDragging in dragMonitor.$isDraggingImages.values {
        if isDragging {
          handleDrag()
        } else {
          handleMouseUp()
        }
      }
    }
  }

  private func setupConversionBatchHandler() {
    viewModel.$currentBatch
      .compactMap { $0 }
      .map { $0.status }
      .removeDuplicates()
      .sink { [weak self] status in
        if status == .completed {
          // Add a small delay to show the completion state
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self?.viewModel.state.autoCloseAfterConversion == true {
              DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self?.hideFloatingPanel()
              }
            }
          }
        }
      }
      .store(in: &cancellables)
  }

  private func handleDrag() {
    print("🔍 handleDrag - Current visibility:", isDropZoneVisible)
    if let urls = dragMonitor.getImageURLs() {
      print("📁 Got image URLs:", urls)
      viewModel.draggedFileURLs = urls
      showFloatingPanel()
    }
  }

  private func handleMouseUp() {
    print("👆 Mouse up detected")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      print(
        "🔍 Checking if should hide panel - Batch:", self.viewModel.currentBatch != nil,
        "Files:", !self.viewModel.draggedFileURLs.isEmpty,
        "Dragging:", self.dragMonitor.isDraggingImages
      )

      // Hide panel if:
      // 1. No active conversion batch AND
      // 2. No dragged files OR not dragging anymore
      if self.viewModel.currentBatch == nil
        && (self.viewModel.draggedFileURLs.isEmpty || !self.dragMonitor.isDraggingImages)
      {
        self.hideFloatingPanel()
      }
    }
  }

  private func showFloatingPanel() {
    print("📱 Showing floating panel")
    isDropZoneVisible = true
    openWindow?("dropzone")
    print("✅ Panel visibility set to true")
  }

  private func hideFloatingPanel() {
    print("🚫 Hiding floating panel")

    // First update state and trigger animation
    isDropZoneVisible = false
    viewModel.draggedFileURLs = []
    viewModel.currentBatch = nil
    print("✅ Panel visibility set to false")

    // Wait for animation to complete before dismissing window
    Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(380))  // Match animation duration
      print("🔒 Dismissing window after animation")
      dismissWindow?("dropzone")
    }
  }
}
