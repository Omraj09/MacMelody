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
                if let profiles = manager.customEqualizers {
                    Section("Custom EQ Profiles") {
                        ForEach([UInt8(4), 5, 6], id: \.self) { id in
                            CustomEQEditor(id: id, saved: profiles.first { $0.id == id })
                        }
                        OperationStatusLine(status: manager.status(of: .customEqualizer))
                    }
                }
                if !manager.dynamicAudio.isEmpty {
                    Section {
                        ForEach(manager.dynamicAudio) { band in
                            Stepper(value: Binding(get: { band.value }, set: { value in Task { await manager.setDynamicAudio(band, value: value) } }), in: band.minimum...band.maximum) {
                                HStack {
                                    Text(band.id == 1 ? "Low" : band.id == 2 ? "Mid" : "High")
                                    Spacer()
                                    Text("\(band.value > 0 ? "+" : "")\(band.value)").monospacedDigit().foregroundStyle(.secondary)
                                }
                            }
                            .disabled(manager.status(of: .dynamicAudio) == .pending || manager.features[0x26] != true)
                        }
                        OperationStatusLine(status: manager.status(of: .dynamicAudio))
                    } header: {
                        SectionHeader(title: "Dynamic Audio", presentation: manager.presentation(.dynamicAudio))
                    } footer: {
                        FormFooter("Enable Dynamic audio in Overview to adjust the low, mid and high bands.")
                    }
                }
                Section {
                    VStack(spacing: 0) {
                        EqualizerPresetGrid(presets: presets)
                        OperationStatusLine(status: manager.status(of: .equalizer))
                    }
                    .padding(.vertical, Theme.Spacing.xs)
                } header: {
                    SectionHeader(title: "Equalizer Presets", presentation: manager.presentation(.equalizer))
                } footer: {
                    FormFooter("Select an equalizer profile tuned specifically for your earbuds' acoustic hardware.")
                }
            }
            .screenFormStyle()
        }
    }
}
