import OneBudsCore
import SwiftUI

/// Connected content of the popover; driven by BudsViewModel for noise control, ANC depth,
/// and game mode, plus battery and advanced audio toggles.
struct PopoverControls: View {
    @Environment(DeviceManager.self) private var manager
    @StateObject private var viewModel = BudsViewModel()
    @State private var isCustomEQExpanded = false

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

                    // Custom EQ Expand Toggle Button
                    Button {
                        withAnimation(Theme.Motion.standard) {
                            isCustomEQExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "waveform.path")
                                .font(.caption2)
                            Text(isCustomEQExpanded ? "Hide Custom EQ Studio" : "Custom EQ Studio…")
                                .font(.caption.weight(.medium))
                            Spacer()
                            Image(systemName: isCustomEQExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    if isCustomEQExpanded {
                        CustomEQCurveView()
                            .padding(.top, 4)
                    }
                }
            }

            // BassWave™ Toggle Card (shown when model supports BassWave)
            if manager.presentation(.bassWave) != .hidden,
               let id = manager.profile?.opo?.bassWaveFeatureID {
                Card {
                    VStack(spacing: 8) {
                        HStack {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text("BassWave™")
                                            .font(.subheadline.bold())
                                        CapabilityBadge(presentation: manager.presentation(.bassWave))
                                    }
                                    Text(manager.bassWaveLevel > 0 ? "Dynamic bass: \(bassLevelDescription(manager.bassWaveLevel))" : "Dynamic algorithm bass enhancement")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: "waveform.path.badge.plus")
                                    .font(.title3)
                                    .foregroundStyle(manager.bassWaveLevel > 0 ? Color.accentColor : Color.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { manager.bassWaveLevel > 0 },
                                set: { enabled in
                                    Task { await manager.setFeature(id, enabled: enabled) }
                                }
                            ))
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .disabled(manager.status(of: .feature(id)) == .pending)
                        }

                        if manager.bassWaveLevel > 0 {
                            HStack(spacing: 6) {
                                ForEach(1...4, id: \.self) { level in
                                    let isSelected = manager.bassWaveLevel == level
                                    Button {
                                        Task { await manager.setBassWaveLevel(level) }
                                    } label: {
                                        VStack(spacing: 2) {
                                            Text("Level \(level)")
                                                .font(.caption.bold())
                                            Text(bassLevelShortName(level))
                                                .font(.system(size: 8))
                                                .foregroundStyle(isSelected ? Color.white.opacity(0.9) : .secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 5)
                                        .background {
                                            if isSelected {
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(Color.accentColor)
                                            } else {
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(Color.secondary.opacity(0.08))
                                            }
                                        }
                                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(manager.status(of: .feature(id)) == .pending)
                                }
                            }
                            .padding(.top, 2)
                        }
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
        .onChange(of: manager.featureRawValues) { _, _ in viewModel.syncFromHardware() }
        .onChange(of: manager.connection) { _, _ in viewModel.syncFromHardware() }
    }

    private func bassLevelDescription(_ level: Int) -> String {
        switch level {
        case 1: "Level 1 (Mild)"
        case 2: "Level 2 (Balanced)"
        case 3: "Level 3 (Punchy)"
        case 4: "Level 4 (Max)"
        default: "Off"
        }
    }

    private func bassLevelShortName(_ level: Int) -> String {
        switch level {
        case 1: "Mild"
        case 2: "Balanced"
        case 3: "Punchy"
        case 4: "Max"
        default: ""
        }
    }
}
