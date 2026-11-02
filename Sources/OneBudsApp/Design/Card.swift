import SwiftUI

/// A grouped container for the popover, matching grouped-form section styling.
struct Card<Content: View>: View {
    @Environment(\.visualStyle) private var visualStyle
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ViewBuilder let content: () -> Content

    private var isDark: Bool { colorScheme == .dark }
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m - 2, content: content)
            .padding(Theme.Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if visualStyle == .glass && !reduceTransparency {
                    ZStack {
                        shape.fill(Color.white.opacity(isDark ? 0.07 : 0.45))
                        shape.fill(
                            LinearGradient(
                                colors: [.white.opacity(isDark ? 0.12 : 0.35), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    }
                } else {
                    // Standard: completely translucent card surface
                    shape.fill(Color.primary.opacity(isDark ? 0.06 : 0.04))
                }
            }
            .overlay {
                if visualStyle == .glass && !reduceTransparency {
                    shape.strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(isDark ? 0.35 : 0.85),
                                .white.opacity(isDark ? 0.05 : 0.20)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                } else {
                    shape.strokeBorder(
                        Color.primary.opacity(isDark ? 0.09 : 0.06),
                        lineWidth: 0.5
                    )
                }
            }
            .clipShape(shape)
    }
}
