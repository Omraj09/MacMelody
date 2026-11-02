import OneBudsCore
import SwiftUI

/// Connected content of the menu bar panel, dynamically rendered according to the user's
/// customized module order, enabled modules, and orientation layout (stacked vs modern tiles).
struct PopoverControls: View {
    @Environment(AppModel.self) private var model
    @Environment(DeviceManager.self) private var manager
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = BudsViewModel()

    private var activeModules: [PanelModule] {
        model.settings.panelModuleOrder.filter {
            model.settings.isModuleEnabled($0) && isSupported($0)
        }
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.m - 2) {
            if model.settings.panelOrientation == .modernGrid {
                renderModernGridLayout()
            } else {
                renderStackedLayout()
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

    // MARK: - Stacked Layout (Full Cards)

    @ViewBuilder
    private func renderStackedLayout() -> some View {
        ForEach(activeModules) { module in
            renderModule(module)
        }
    }

    // MARK: - Modern Grid Layout (Control Center Style)

    @ViewBuilder
    private func renderModernGridLayout() -> some View {
        let compacts = activeModules.filter(\.isCompactTile)

        // Render full width cards in their order, but group compact tiles together as modern tiles
        ForEach(activeModules) { module in
            if !module.isCompactTile {
                renderModule(module)
            } else if module == compacts.first {
                // Render all active compact modules together in a 2-column Control Center tile grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    ForEach(compacts) { compactModule in
                        renderCompactTile(compactModule)
                    }
                }
            }
        }
    }

    // MARK: - Module Renderers

    @ViewBuilder
    private func renderModule(_ module: PanelModule) -> some View {
        switch module {
        case .battery:
            batteryCard()
        case .noiseControl:
            noiseControlCard()
        case .gameMode:
            gameModeCard()
        case .equalizer:
            equalizerCard()
        case .inEarDetection:
            inEarDetectionCard()
        case .spatialAudio:
            spatialAudioCard()
        }
    }

    // MARK: - Battery Card

    @ViewBuilder
    private func batteryCard() -> some View {
        if let battery = manager.battery, !battery.isEmpty {
            Card {
                SectionHeader(title: "Battery", presentation: manager.presentation(.battery))
                    .font(.subheadline.bold())
                BatteryRow(battery: battery)
            }
        }
    }

    // MARK: - Noise Control Card

    @ViewBuilder
    private func noiseControlCard() -> some View {
        Card {
            HStack {
                Text("Noise Control")
                    .font(.subheadline.bold())
                Spacer()
                Text(viewModel.noiseMode.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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
    }

    // MARK: - Game Mode Card

    @ViewBuilder
    private func gameModeCard() -> some View {
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

    // MARK: - Equalizer Presets Card

    @ViewBuilder
    private func equalizerCard() -> some View {
        if let presets = manager.profile?.opo?.equalizerPresets, !presets.isEmpty {
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

    // MARK: - In-Ear Detection Card

    @ViewBuilder
    private func inEarDetectionCard() -> some View {
        if let id = manager.profile?.opo?.wearDetectionFeatureID,
           let isEnabled = manager.features[id] {
            Card {
                HStack {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("In-Ear Detection")
                                .font(.subheadline.bold())
                            Text("Auto pause/resume")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "ear")
                            .font(.title3)
                            .foregroundStyle(isEnabled ? Color.accentColor : Color.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { manager.features[id] ?? false },
                        set: { val in Task { await manager.setFeature(id, enabled: val) } }
                    ))
                    .toggleStyle(.switch)
                    .labelsHidden()
                }
            }
        }
    }

    // MARK: - Spatial Audio Card

    @ViewBuilder
    private func spatialAudioCard() -> some View {
        if let id = manager.profile?.opo?.spatialAudioFeatureID,
           let isEnabled = manager.features[id] {
            Card {
                HStack {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Spatial Audio")
                                .font(.subheadline.bold())
                            Text("360° fixed spatial sound")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .font(.title3)
                            .foregroundStyle(isEnabled ? Color.accentColor : Color.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { manager.features[id] ?? false },
                        set: { val in Task { await manager.setFeature(id, enabled: val) } }
                    ))
                    .toggleStyle(.switch)
                    .labelsHidden()
                }
            }
        }
    }

    // MARK: - Compact Tile (Control Center Grid)

    @ViewBuilder
    private func renderCompactTile(_ module: PanelModule) -> some View {
        switch module {
        case .gameMode:
            ControlCenterTile(
                symbol: "gamecontroller",
                title: "Game Mode",
                subtitle: viewModel.isGameMode ? "Low Latency" : "Normal",
                isOn: viewModel.isGameMode
            ) {
                viewModel.toggleGameMode()
            }
        case .inEarDetection:
            if let id = manager.profile?.opo?.wearDetectionFeatureID,
               let isEnabled = manager.features[id] {
                ControlCenterTile(
                    symbol: "ear",
                    title: "In-Ear",
                    subtitle: isEnabled ? "Auto-Pause" : "Off",
                    isOn: isEnabled
                ) {
                    Task { await manager.setFeature(id, enabled: !isEnabled) }
                }
            }
        case .spatialAudio:
            if let id = manager.profile?.opo?.spatialAudioFeatureID,
               let isEnabled = manager.features[id] {
                ControlCenterTile(
                    symbol: "dot.radiowaves.left.and.right",
                    title: "Spatial",
                    subtitle: isEnabled ? "360° Audio" : "Off",
                    isOn: isEnabled
                ) {
                    Task { await manager.setFeature(id, enabled: !isEnabled) }
                }
            }
        default:
            EmptyView()
        }
    }

    private func isSupported(_ module: PanelModule) -> Bool {
        guard let profile = manager.profile else { return true }
        switch module {
        case .battery:
            return manager.presentation(.battery) != .hidden && !(manager.battery?.isEmpty ?? true)
        case .noiseControl:
            return manager.presentation(.noiseControl) != .hidden && !(profile.opo?.noiseModes.isEmpty ?? true)
        case .gameMode:
            return manager.presentation(.gameMode) != .hidden
        case .equalizer:
            return manager.presentation(.equalizer) != .hidden && !(profile.opo?.equalizerPresets.isEmpty ?? true)
        case .inEarDetection:
            return profile.opo?.wearDetectionFeatureID != nil && manager.presentation(.wearDetection) != .hidden
        case .spatialAudio:
            return profile.opo?.spatialAudioFeatureID != nil && manager.presentation(.spatialAudio) != .hidden
        }
    }
}

/// A compact Control Center-style tile with icon, title, and active glow border.
private struct ControlCenterTile: View {
    let symbol: String
    let title: String
    let subtitle: String
    let isOn: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isOn ? Color.accentColor : Color.secondary)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(isOn ? Color.accentColor.opacity(colorScheme == .dark ? 0.28 : 0.16) : Color.secondary.opacity(0.10))
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .fill(isOn ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                            .strokeBorder(isOn ? Color.accentColor.opacity(0.40) : Color.primary.opacity(0.06), lineWidth: 1)
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
