import OneBudsCore
import SwiftUI

/// Game mode, in-ear detection and dual connection, each shown only if the profile supports it
/// and the earbuds reported a value.
struct FeatureTogglesSection: View {
    @Environment(DeviceManager.self) private var manager

    private struct Row: Identifiable {
        let capability: Capability
        let featureID: UInt8
        let symbol: String
        var id: UInt8 { featureID }
    }

    private var rows: [Row] {
        guard let opo = manager.profile?.opo else { return [] }
        let candidates: [(Capability, UInt8?, String)] = [
            (.gameMode, opo.gameModeFeatureID, "gamecontroller"),
            (.wearDetection, opo.wearDetectionFeatureID, "ear"),
            (.dualConnection, opo.dualConnectionFeatureID, "laptopcomputer.and.iphone"),
            (.spatialAudio, opo.spatialAudioFeatureID, "surroundsound"),
            (.dynamicAudio, opo.dynamicAudioFeatureID, "slider.horizontal.3"),
        ]
        return candidates.compactMap { capability, id, symbol in
            guard let id, manager.presentation(capability) != .hidden, manager.features[id] != nil else { return nil }
            return Row(capability: capability, featureID: id, symbol: symbol)
        }
    }

    var body: some View {
        if !rows.isEmpty || manager.highVolume != nil {
            Section("Features") {
                ForEach(rows) { row in
                    FeatureToggleRow(capability: row.capability, featureID: row.featureID, symbol: row.symbol)
                }
                if manager.profile?.id == "realme-buds-air-8" {
                    ForEach([(UInt8(5), "Power saving"), (8, "Auto answer"), (9, "Enhance voices"), (12, "Enhance call voices"), (24, "High-definition sound"), (26, "Wind noise reduction"), (29, "Dynamic bass")], id: \.0) { id, title in
                        if let enabled = manager.features[id] {
                            VStack(alignment: .leading) {
                                Toggle(title, isOn: Binding(get: { enabled }, set: { value in Task { await manager.setFeature(id, enabled: value) } }))
                                    .toggleStyle(.switch).disabled(manager.status(of: .feature(id)) == .pending)
                                if id == 5 || id == 24 {
                                    Text(id == 5 ? "Changing this may restart the earbuds." : "Changing this may disconnect the earbuds; macOS codec support varies.")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                OperationStatusLine(status: manager.status(of: .feature(id)))
                            }
                        }
                    }
                }
                if let highVolume = manager.highVolume {
                    VStack(alignment: .leading) {
                        Toggle("High volume mode", isOn: Binding(get: { highVolume }, set: { value in Task { await manager.setHighVolume(value) } }))
                            .toggleStyle(.switch)
                            .disabled(manager.status(of: .highVolume) == .pending)
                        Text("Lifts the earbud volume limit. Lower your volume before enabling.").font(.caption).foregroundStyle(.secondary)
                        OperationStatusLine(status: manager.status(of: .highVolume))
                    }
                }
            }
        }
    }
}
