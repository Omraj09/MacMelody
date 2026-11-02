import SwiftUI

/// Window-level style: content area is completely translucent (desktop blur shows through).
struct WindowGlass: ViewModifier {
    @Environment(\.visualStyle) private var visualStyle
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    func body(content: Content) -> some View {
        if reduceTransparency {
            content
        } else {
            content
                .scrollContentBackground(.hidden)
                .background {
                    ZStack {
                        VisualEffectBackground(material: .underWindowBackground, state: .active)
                        if visualStyle == .glass {
                            LinearGradient(
                                colors: [
                                    .white.opacity(isDark ? 0.08 : 0.25),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        } else {
                            // Standard: completely translucent native vibrancy
                            Color(nsColor: .windowBackgroundColor).opacity(isDark ? 0.10 : 0.18)
                        }
                    }
                    .ignoresSafeArea()
                }
        }
    }
}

extension View {
    /// Grouped form styling for main-window screens, translucent under the Glass style.
    func screenFormStyle() -> some View {
        formStyle(.grouped).modifier(WindowGlass())
    }

    func windowGlass() -> some View {
        modifier(WindowGlass())
    }
}
