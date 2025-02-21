import SwiftUI

struct WindowVisibilityModifier: ViewModifier {
  let isVisible: Bool

  func body(content: Content) -> some View {
    content
      .opacity(isVisible ? 1 : 0)
      .scaleEffect(isVisible ? 1 : 0.95)
      .blur(radius: isVisible ? 0 : 16)
      .animation(isVisible ? .smooth : .snappy, value: isVisible)
  }
}

extension View {
  func windowVisibility(_ isVisible: Bool) -> some View {
    modifier(WindowVisibilityModifier(isVisible: isVisible))
  }
}
