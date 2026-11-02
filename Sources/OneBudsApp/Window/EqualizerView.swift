import OneBudsCore
import SwiftUI

struct EqualizerView: View {
    @Environment(DeviceManager.self) private var manager

    /// Presets the profile offers, minus those that need newer firmware than the earbuds report.
    private var presets: [EQPresetOption] {
        let firmware = manager.deviceInfo?.firmwareSummary.flatMap { Int($0.split(separator: ".").first ?? "") }
        return (manager.profile?.opo?.equalizerPresets ?? []).filter { preset in
            guard let minimum = preset.minimumFirmware else { return true }
            return firmware.map { $0 >= minimum } ?? false
        }
    }

    var body: some View {
        RequiresCapability(capability: .equalizer) {
            Form {
                if !presets.isEmpty {
                    Section {
                        VStack(spacing: 0) {
                            EqualizerPresetGrid(presets: presets)
                            OperationStatusLine(status: manager.status(of: .equalizer))
                        }
                        .padding(.vertical, Theme.Spacing.xs)
                    } header: {
                        SectionHeader(title: "Equalizer Presets", presentation: manager.presentation(.equalizer))
                    }
                }

                Section {
                    CustomEQCurveView()
                        .padding(.vertical, Theme.Spacing.xs)
                } header: {
                    SectionHeader(title: "Custom EQ Studio", presentation: manager.presentation(.equalizer))
                } footer: {
                    FormFooter("Adjust 6 frequency bands from -6 dB to +6 dB. Changes apply directly to your earbuds.")
                }

                if manager.presentation(.bassWave) != .hidden,
                   let bassID = manager.profile?.opo?.bassWaveFeatureID {
                    Section {
                        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text("BassWave™ Dynamic Enhancement")
                                                .font(.headline)
                                            CapabilityBadge(presentation: manager.presentation(.bassWave))
                                        }
                                        Text("Active low-frequency dynamic compensation algorithm matching HeyMelody.")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                } icon: {
                                    Image(systemName: "waveform.path.badge.plus")
                                        .font(.title2)
                                        .foregroundStyle(manager.bassWaveLevel > 0 ? Color.accentColor : Color.secondary)
                                }

                                Spacer()

                                Toggle("", isOn: Binding(
                                    get: { manager.bassWaveLevel > 0 },
                                    set: { enabled in
                                        Task { await manager.setFeature(bassID, enabled: enabled) }
                                    }
                                ))
                                .toggleStyle(.switch)
                                .labelsHidden()
                                .disabled(manager.status(of: .feature(bassID)) == .pending)
                            }

                            if manager.bassWaveLevel > 0 {
                                Divider()

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("BassWave Level")
                                            .font(.subheadline.weight(.medium))
                                        Spacer()
                                        Text(bassLevelDescription(manager.bassWaveLevel))
                                            .font(.caption.bold())
                                            .foregroundStyle(Color.accentColor)
                                    }

                                    HStack(spacing: 10) {
                                        ForEach(1...4, id: \.self) { level in
                                            let isSelected = manager.bassWaveLevel == level
                                            Button {
                                                Task { await manager.setBassWaveLevel(level) }
                                            } label: {
                                                VStack(spacing: 4) {
                                                    Text("Level \(level)")
                                                        .font(.caption.bold())
                                                    Text(bassLevelShortName(level))
                                                        .font(.system(size: 9))
                                                        .foregroundStyle(isSelected ? Color.white.opacity(0.9) : .secondary)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 8)
                                                .background {
                                                    if isSelected {
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .fill(Color.accentColor)
                                                    } else {
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .fill(Color.secondary.opacity(0.1))
                                                    }
                                                }
                                                .foregroundStyle(isSelected ? Color.white : Color.primary)
                                            }
                                            .buttonStyle(.plain)
                                            .disabled(manager.status(of: .feature(bassID)) == .pending)
                                        }
                                    }
                                }
                            }

                            OperationStatusLine(status: manager.status(of: .feature(bassID)))
                        }
                        .padding(.vertical, Theme.Spacing.xs)
                    } header: {
                        SectionHeader(title: "BassWave™", presentation: manager.presentation(.bassWave))
                    }
                }
            }
            .screenFormStyle()
        }
    }

    private func bassLevelDescription(_ level: Int) -> String {
        switch level {
        case 1: "Level 1: Mild (+1 dB dynamic bass)"
        case 2: "Level 2: Balanced (+2 dB dynamic bass)"
        case 3: "Level 3: Punchy (+3 dB dynamic bass)"
        case 4: "Level 4: Maximum (+4 dB dynamic bass)"
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
