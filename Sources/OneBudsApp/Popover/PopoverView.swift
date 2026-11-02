import OneBudsCore
import SwiftUI

/// The primary interface: battery, noise control and quick toggles, one click from the menu bar.
struct PopoverView: View {
    @Environment(DeviceManager.self) private var manager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.visualStyle) private var visualStyle
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var isDark: Bool { colorScheme == .dark }
    private var outerShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Radius.popover, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            PopoverHeader()

            if manager.connection.isConnected {
                PopoverControls()
                    .transition(.opacity)
            } else {
                CompactConnectionStateView()
                    .transition(.opacity)
            }

            if let error = manager.lastError, manager.connection.isConnected {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }

            Divider()
                .opacity(0.5)
            PopoverFooter()
        }
        .padding(Theme.Spacing.l)
        .frame(width: Theme.Size.popoverWidth)
        .background {
            ZStack {
                VisualEffectBackground(material: .popover, state: .active)
                if visualStyle == .glass && !reduceTransparency {
                    Color.white.opacity(isDark ? 0.06 : 0.20)
                    LinearGradient(
                        colors: [
                            .white.opacity(isDark ? 0.18 : 0.45),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                } else {
                    // Standard: clean completely translucent vibrancy
                    Color(nsColor: .windowBackgroundColor).opacity(isDark ? 0.15 : 0.25)
                }
            }
        }
        .overlay {
            if visualStyle == .glass && !reduceTransparency {
                outerShape.strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(isDark ? 0.45 : 0.85),
                            .white.opacity(isDark ? 0.08 : 0.22)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            } else {
                outerShape.strokeBorder(
                    Color.primary.opacity(isDark ? 0.14 : 0.09),
                    lineWidth: 1
                )
            }
        }
        .clipShape(outerShape)
        .animateState(value: manager.connection.isConnected)
        .animateState(value: manager.lastError)
    }
}
