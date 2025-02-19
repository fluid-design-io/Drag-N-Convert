import AppKit
import Combine
import SwiftUI

@MainActor
final class WindowManager: ObservableObject {
  private var floatingPanel: FloatingPanel?
  private let dragMonitor: DragMonitor
  private var viewModel: AppViewModel
  private var cancellables = Set<AnyCancellable>()

  private let windowPadding: CGFloat = 20
  private let desiredWidth: CGFloat = 420
  private let initialHeight: CGFloat = 200

  init(viewModel: AppViewModel) {
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
              DispatchQueue.main.asyncAfter(
                deadline:
                  .now() + 3
              ) {
                self?.hideFloatingPanel()
              }
            }
          }
        }
      }
      .store(in: &cancellables)
  }

  private func handleDrag() {
    // ignore if already showing the drop zone
    guard !viewModel.isDropZoneVisible else { return }

    if let urls = dragMonitor.getImageURLs() {
      viewModel.draggedFileURLs = urls
      showFloatingPanel()
    }
  }

  private func handleMouseUp() {
    // delay checking for successful drop
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // Only hide if we're not actively converting
      if self.viewModel.currentBatch == nil {
        self.hideFloatingPanel()
      }
    }
  }

  private func showFloatingPanel() {
    guard floatingPanel == nil else { return }

    let screenFrame = NSScreen.main?.visibleFrame ?? .zero
    let panelSize = NSSize(width: desiredWidth, height: initialHeight)
    let panelOrigin = NSPoint(
      x: screenFrame.maxX - panelSize.width - windowPadding,
      y: screenFrame.midY - panelSize.height / 2
    )

    let panel = FloatingPanel(
      contentRect: NSRect(origin: panelOrigin, size: panelSize),
      backing: .buffered,
      defer: false
    )

    let hostingView = NSHostingView(
      rootView: DropZoneView()
        .environmentObject(viewModel)
    )
    panel.contentView = hostingView

    // Start with 0 alpha and slightly offset position
    panel.alphaValue = 0.0
    panel.setFrame(
      NSRect(
        origin: NSPoint(x: panel.frame.origin.x + windowPadding, y: panel.frame.origin.y),
        size: panel.frame.size
      ), display: false)

    panel.orderFront(nil)

    // Animate to final position and full opacity
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.2
      context.timingFunction = CAMediaTimingFunction(name: .default)
      panel.animator().alphaValue = 1.0
      panel.animator().setFrame(NSRect(origin: panelOrigin, size: panelSize), display: true)
    }

    self.floatingPanel = panel
    viewModel.isDropZoneVisible = true
  }

  private func hideFloatingPanel() {
    guard let panel = floatingPanel else { return }

    // Animate out
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.2
      context.timingFunction = CAMediaTimingFunction(name: .default)
      panel.animator().alphaValue = 0.0
      panel.animator().setFrame(
        NSRect(
          origin: NSPoint(x: panel.frame.origin.x + windowPadding, y: panel.frame.origin.y),
          size: panel.frame.size
        ), display: true)
    } completionHandler: {
      panel.close()
      self.floatingPanel = nil
      self.viewModel.isDropZoneVisible = false

      // Reset all states after hiding the panel
      self.viewModel.draggedFileURLs = []
      self.viewModel.currentBatch = nil
    }

  }
}
