import OneBudsCore
import SwiftUI

/// Connected content of the popover; driven by BudsViewModel for noise control, ANC depth,
/// and game mode, plus battery and advanced audio toggles.
struct PopoverControls: View {
    @Environment(DeviceManager.self) private var manager
    @StateObject private var viewModel = BudsViewModel()

    var body: some View {
        VStack(spacing: Theme.Spacing.m - 2) {
            if manager.presentation(.battery) != .hidden, let battery = manager.battery, !battery.isEmpty {
                Card {
                    SectionHeader(title: "Battery", presentation: manager.presentation(.battery))
                        .font(.subheadline.bold())
                    BatteryRow(battery: battery)
                }
            }

            // Control UI driven by BudsViewModel
            BudsControlView(viewModel: viewModel)

            // Equalizer Presets Card (shown when model supports EQ presets)
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

            // BassWave™ Toggle Card (shown when model supports BassWave)
            if manager.presentation(.bassWave) != .hidden,
               let id = manager.profile?.opo?.bassWaveFeatureID {
                Card {
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("BassWave™")
                                        .font(.subheadline.bold())
                                    CapabilityBadge(presentation: manager.presentation(.bassWave))
                                }
                                Text("Dynamic algorithm bass enhancement")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "waveform.path.badge.plus")
                                .font(.title3)
                                .foregroundStyle((manager.features[id] ?? false) ? Color.accentColor : Color.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { manager.features[id] ?? false },
                            set: { enabled in
                                Task { await manager.setFeature(id, enabled: enabled) }
                            }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .disabled(manager.status(of: .feature(id)) == .pending)
                    }
                }
            }

            // Spatial Audio Toggle Card (shown when model supports spatial audio)
            if manager.presentation(.spatialAudio) != .hidden,
               let id = manager.profile?.opo?.spatialAudioFeatureID {
                Card {
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("Spatial Audio")
                                        .font(.subheadline.bold())
                                    CapabilityBadge(presentation: manager.presentation(.spatialAudio))
                                }
                                Text("360° immersive audio effect")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "dot.radiowaves.left.and.right")
                                .font(.title3)
                                .foregroundStyle((manager.features[id] ?? false) ? Color.accentColor : Color.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { manager.features[id] ?? false },
                            set: { enabled in
                                Task { await manager.setFeature(id, enabled: enabled) }
                            }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .disabled(manager.status(of: .feature(id)) == .pending)
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
