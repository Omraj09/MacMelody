import OneBudsCore
import SwiftUI

struct DeviceInfoView: View {
    @Environment(DeviceManager.self) private var manager

    var body: some View {
        if !manager.connection.isConnected {
            ConnectionStateView()
        } else {
            Form {
                Section("Model") {
                    LabeledContent("Name", value: manager.earbuds?.name ?? "—")
                    LabeledContent("Profile", value: manager.profile?.model ?? "—")
                    LabeledContent("Product ID", value: manager.deviceInfo?.productID ?? "—")
                    LabeledContent("Protocol", value: manager.profile?.protocolKind.rawValue ?? "—")
                    LabeledContent("Support") {
                        if let profile = manager.profile { Badge.status(profile.status) }
                    }
                }
                Section("Firmware") {
                    LabeledContent("Version", value: manager.deviceInfo?.firmwareSummary ?? "Not reported")
                    ForEach(manager.deviceInfo?.firmware ?? [], id: \.displayID) { component in
                        LabeledContent("\(component.componentName) (type \(component.versionType))", value: component.version)
                    }
                }
                if manager.profile?.id == "realme-buds-air-8" && (!manager.wear.isEmpty || !manager.listeningTime.isEmpty) {
                    Section("Earbuds") {
                        ForEach([UInt8(1), UInt8(2)], id: \.self) { id in
                            let side = id == 1 ? "Left" : "Right"
                            if let flags = manager.wear[id] {
                                LabeledContent("\(side) status", value: flags & 1 == 0 ? "In case" : flags & 2 != 0 ? "In ear" : "Out")
                            }
                            if let minutes = manager.listeningTime[id] {
                                LabeledContent("\(side) listening time", value: "\(minutes / 60)h \(minutes % 60)m")
                            }
                        }
                    }
                }
                Section("Connection") {
                    LabeledContent("Transport", value: manager.transportKind?.displayName ?? "—")
                    if let detail = manager.transportDetail { LabeledContent("Channel", value: detail) }
                    LabeledContent("Found via", value: manager.earbuds?.discoveryPaths.joined(separator: ", ") ?? "—")
                    LabeledContent("Capability bits", value: "\(manager.deviceInfo?.capabilityBits.count ?? 0) reported")
                }
            }
            .screenFormStyle()
            .textSelection(.enabled)
        }
    }
}
