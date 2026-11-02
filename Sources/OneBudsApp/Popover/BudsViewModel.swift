import Foundation
import OneBudsCore
import SwiftUI

enum NoiseControlMode: String, CaseIterable, Identifiable {
    case off = "Off"
    case anc = "ANC"
    case transparency = "Transparency"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .off: return "speaker.slash.fill"
        case .anc: return "person.wave.2.fill"
        case .transparency: return "ear"
        }
    }
}

enum ANCDepth: String, CaseIterable, Identifiable {
    case smart = "Smart"
    case deep = "Deep"
    case medium = "Medium"
    case light = "Light"

    var id: String { rawValue }
}

@MainActor
final class BudsViewModel: ObservableObject {
    @Published var deviceName: String = "OnePlus Nord Buds 4 Pro"
    @Published var isConnected: Bool = true
    @Published var leftBattery: Int = 70
    @Published var rightBattery: Int = 70

    @Published var noiseMode: NoiseControlMode = .anc
    @Published var ancDepth: ANCDepth = .smart
    @Published var isGameMode: Bool = false

    var menuBarBatteryText: String {
        "\(min(leftBattery, rightBattery))%"
    }

    private weak var manager: DeviceManager?
    private var isUpdatingFromHardware = false

    func attach(manager: DeviceManager) {
        self.manager = manager
        syncFromHardware()
    }

    func syncFromHardware() {
        guard let manager else { return }
        isUpdatingFromHardware = true
        defer { isUpdatingFromHardware = false }

        if let name = manager.earbuds?.name {
            deviceName = name
        }
        isConnected = manager.connection.isConnected

        if let battery = manager.battery {
            if let left = battery.left?.percent {
                leftBattery = Int(left)
            }
            if let right = battery.right?.percent {
                rightBattery = Int(right)
            }
        }

        if let nc = manager.noiseControl {
            switch nc {
            case .off:
                noiseMode = .off
            case .transparency:
                noiseMode = .transparency
            case .noiseCancelling(let level):
                noiseMode = .anc
                if let level {
                    switch level {
                    case .smart: ancDepth = .smart
                    case .deep: ancDepth = .deep
                    case .medium: ancDepth = .medium
                    case .light: ancDepth = .light
                    }
                }
            case .adaptive:
                noiseMode = .anc
            }
        }

        if let id = manager.profile?.opo?.gameModeFeatureID, let val = manager.features[id] {
            isGameMode = val
        }
    }

    // MARK: - Hardware Command Hooks (Connect your BLE / RFCOMM writer here)

    func setNoiseMode(_ mode: NoiseControlMode) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.74)) {
            noiseMode = mode
        }
        // Send ANC mode packet to buds
        guard let manager, !isUpdatingFromHardware else { return }
        Task {
            switch mode {
            case .off:
                await manager.setNoiseControl(.off)
            case .transparency:
                await manager.setNoiseControl(.transparency)
            case .anc:
                let level: OneBudsCore.ANCLevel
                switch ancDepth {
                case .smart: level = .smart
                case .deep: level = .deep
                case .medium: level = .medium
                case .light: level = .light
                }
                await manager.setNoiseControl(.noiseCancelling(level))
            }
        }
    }

    func setANCDepth(_ depth: ANCDepth) {
        withAnimation(.spring(response: 0.36, dampingFraction: 0.76)) {
            ancDepth = depth
        }
        // Send ANC depth packet to buds
        guard let manager, !isUpdatingFromHardware else { return }
        Task {
            let level: OneBudsCore.ANCLevel
            switch depth {
            case .smart: level = .smart
            case .deep: level = .deep
            case .medium: level = .medium
            case .light: level = .light
            }
            await manager.setNoiseControl(.noiseCancelling(level))
        }
    }

    func toggleGameMode() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.68)) {
            isGameMode.toggle()
        }
        // Send low-latency Game Mode packet to buds
        guard let manager, !isUpdatingFromHardware else { return }
        let id = manager.profile?.opo?.gameModeFeatureID ?? 0x06
        let target = isGameMode
        Task {
            await manager.setFeature(id, enabled: target)
        }
    }
}
