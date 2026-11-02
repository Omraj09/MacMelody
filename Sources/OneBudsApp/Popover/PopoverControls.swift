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

            if manager.presentation(.spatialAudio) != .hidden, let id = manager.profile?.opo?.spatialAudioFeatureID, manager.features[id] != nil {
                Card {
                    FeatureToggleRow(capability: .spatialAudio, featureID: id, symbol: "dot.radiowaves.left.and.right")
                }
            }

            if manager.presentation(.bassWave) != .hidden, let id = manager.profile?.opo?.bassWaveFeatureID, manager.features[id] != nil {
                Card {
                    FeatureToggleRow(capability: .bassWave, featureID: id, symbol: "waveform.path")
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
