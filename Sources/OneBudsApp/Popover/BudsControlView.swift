import SwiftUI

/// Control UI powered by BudsViewModel: Noise Control (Off / ANC / Transparency),
/// ANC Depth (Smart / Deep / Medium / Light), and low-latency Game Mode.
struct BudsControlView: View {
    @ObservedObject var viewModel: BudsViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: Theme.Spacing.m - 2) {
            // Noise Control Card
            Card {
                HStack {
                    Text("Noise Control")
                        .font(.subheadline.bold())
                    Spacer()
                    Text(viewModel.noiseMode.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // 3 Mode Pills: Off, ANC, Transparency
                HStack(spacing: 8) {
                    ForEach(NoiseControlMode.allCases) { mode in
                        Button {
                            viewModel.setNoiseMode(mode)
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: mode.symbol)
                                    .font(.system(size: 16, weight: .semibold))
                                Text(mode.rawValue)
                                    .font(.caption2.weight(.medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background {
                                if viewModel.noiseMode == mode {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.accentColor.opacity(colorScheme == .dark ? 0.28 : 0.16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(Color.accentColor.opacity(0.45), lineWidth: 1)
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.secondary.opacity(0.08))
                                }
                            }
                            .foregroundStyle(viewModel.noiseMode == mode ? Color.accentColor : Color.primary)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                // ANC Depth Picker when ANC mode is selected
                if viewModel.noiseMode == .anc {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ANC Depth")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 6) {
                            ForEach(ANCDepth.allCases) { depth in
                                Button {
                                    viewModel.setANCDepth(depth)
                                } label: {
                                    Text(depth.rawValue)
                                        .font(.caption)
                                        .fontWeight(viewModel.ancDepth == depth ? .semibold : .regular)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 6)
                                        .background {
                                            if viewModel.ancDepth == depth {
                                                Capsule()
                                                    .fill(Color.accentColor)
                                            } else {
                                                Capsule()
                                                    .fill(Color.secondary.opacity(0.10))
                                            }
                                        }
                                        .foregroundStyle(viewModel.ancDepth == depth ? Color.white : Color.primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.top, 4)
                    .transition(.opacity)
                }
            }

            // Game Mode Card
            Card {
                HStack {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Game Mode")
                                .font(.subheadline.bold())
                            Text("Ultra-low latency")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "gamecontroller")
                            .font(.title3)
                            .foregroundStyle(viewModel.isGameMode ? Color.accentColor : Color.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { viewModel.isGameMode },
                        set: { _ in viewModel.toggleGameMode() }
                    ))
                    .toggleStyle(.switch)
                    .labelsHidden()
                }
            }
        }
    }
}
