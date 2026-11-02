import OneBudsCore
import SwiftUI

/// The primary interface: battery, noise control and quick toggles, one click from the menu bar.
struct PopoverView: View {
    @Environment(DeviceManager.self) private var manager
    @Environment(\.colorScheme) private var colorScheme

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
        .surface(outerShape)
        .overlay {
            outerShape.strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(colorScheme == .dark ? 0.38 : 0.75),
                        .white.opacity(colorScheme == .dark ? 0.08 : 0.20)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1
            )
        }
        .clipShape(outerShape)
        .background(WindowTransparentBackground())
        .animateState(value: manager.connection.isConnected)
        .animateState(value: manager.lastError)
    }
}
