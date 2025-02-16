import Cocoa
import UniformTypeIdentifiers

@MainActor
final class DragMonitor: ObservableObject {
  @Published private(set) var isDraggingImages = false
  private var monitor: Any?
  private var lastChangeCount: Int = 0
  private let dragPasteboard = NSPasteboard(name: .drag)

  private static let fileOptions: [NSPasteboard.ReadingOptionKey: Any] = [
    .urlReadingFileURLsOnly: true,
    .urlReadingContentsConformToTypes: [UTType.image.identifier],
    NSPasteboard.ReadingOptionKey(rawValue: "NSPasteboardURLReadingSecurityScopedFileURLsKey"):
      kCFBooleanTrue as Any,
  ]

  init() {
    lastChangeCount = dragPasteboard.changeCount
    setupMonitor()
  }

  deinit {
    if let monitor = monitor {
      NSEvent.removeMonitor(monitor)
    }
  }

  private func setupMonitor() {
    monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged, .leftMouseUp]) {
      [weak self] event in
      Task { @MainActor [weak self] in
        guard let self = self else { return }

        switch event.type {
        case .leftMouseDragged:
          if !self.isDraggingImages {
            let changeCount = self.dragPasteboard.changeCount
            if changeCount != self.lastChangeCount {
              self.lastChangeCount = changeCount
              self.checkForImageFiles()
            }
          }

        case .leftMouseUp:
          self.isDraggingImages = false
          self.lastChangeCount = self.dragPasteboard.changeCount

        default:
          break
        }
      }
    }
  }

  private func checkForImageFiles() {
    if dragPasteboard.canReadObject(forClasses: [NSURL.self], options: Self.fileOptions),
      let urls = dragPasteboard.readObjects(forClasses: [NSURL.self], options: Self.fileOptions)
        as? [URL],
      !urls.isEmpty
    {
      isDraggingImages = true
    }
  }

  func getImageURLs() -> [URL]? {
    guard isDraggingImages,
      dragPasteboard.canReadObject(forClasses: [NSURL.self], options: Self.fileOptions),
      let urls = dragPasteboard.readObjects(forClasses: [NSURL.self], options: Self.fileOptions)
        as? [URL],
      !urls.isEmpty
    else {
      return nil
    }
    return urls
  }
}
