import OneBudsCore
import SwiftUI

/// Connected content of the menu bar panel; strictly focused on:
/// 1. Battery indicators
/// 2. Noise control (Off / ANC / Transparency + ANC depths)
/// 3. Game mode (Ultra-low latency)
/// 4. Equalizer presets (Hardware DSP profiles)
struct PopoverControls: View {
    @Environment(DeviceManager.self) private var manager
    @StateObject private var viewModel = BudsViewModel()

    var body: some View {
        VStack(spacing: Theme.Spacing.m - 2) {
            // 1. Battery Card
            if manager.presentation(.battery) != .hidden, let battery = manager.battery, !battery.isEmpty {
                Card {
                    SectionHeader(title: "Battery", presentation: manager.presentation(.battery))
                        .font(.subheadline.bold())
                    BatteryRow(battery: battery)
                }
            }

            // 2 & 3. Noise Control & Game Mode UI
            BudsControlView(viewModel: viewModel)

            // 4. Equalizer Presets Card (Clean presets grid only)
            if manager.presentation(.equalizer) != .hidden,
               let presets = manager.profile?.opo?.equalizerPresets,
               !presets.isEmpty {
                Card {
                    HStack {
                        Label {
                            Text("Equalizer")
                                .font(.subheadline.bold())
                        } icon: {
                            Image(systemName: "slider.vertical.3")
                                .font(.subheadline)
                                .foregroundStyle(Color.accentColor)
                        }
                        Spacer()
                        if let currentID = manager.equalizerPreset,
                           let currentName = presets.first(where: { $0.id == currentID })?.name {
                            Text(currentName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                        ForEach(presets) { preset in
                            let isSelected = manager.equalizerPreset == preset.id
                            Button {
                                Task { await manager.setEqualizer(presetID: preset.id) }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "waveform")
                                        .font(.caption2)
                                        .foregroundStyle(isSelected ? Color.white : .secondary)
                                    Text(preset.name)
                                        .font(.caption)
                                        .fontWeight(isSelected ? .semibold : .regular)
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.accentColor)
                                    } else {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.secondary.opacity(0.08))
                                    }
                                }
                                .foregroundStyle(isSelected ? Color.white : Color.primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.attach(manager: manager)
        }
        .onChange(of: manager.battery) { _, _ in viewModel.syncFromHardware() }
        .onChange(of: manager.noiseControl) { _, _ in viewModel.syncFromHardware() }
        .onChange(of: manager.features) { _, _ in viewModel.syncFromHardware() }
        .onChange(of: manager.connection) { _, _ in viewModel.syncFromHardware() }
    }
}
