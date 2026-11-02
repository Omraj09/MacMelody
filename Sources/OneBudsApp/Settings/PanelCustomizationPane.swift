import OneBudsCore
import SwiftUI

/// Control Center-style customization pane: configure which modules appear in the menu bar panel,
/// and reorder their orientation/sequence.
struct PanelCustomizationPane: View {
    @Environment(AppModel.self) private var model
    @Environment(DeviceManager.self) private var manager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        @Bindable var settings = model.settings
        Form {
            Section {
                Picker("Layout Style", selection: $settings.panelOrientation) {
                    ForEach(PanelOrientation.allCases) { orientation in
                        Text(orientation.title).tag(orientation)
                    }
                }
                .pickerStyle(.segmented)

                Text(settings.panelOrientation.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Layout & Orientation")
            } footer: {
                FormFooter("Control Center Tiles group compact quick-toggles side-by-side matching macOS 15+ design.")
            }

            Section {
                ForEach(Array(settings.panelModuleOrder.enumerated()), id: \.element.id) { index, module in
                    let isEnabled = settings.isModuleEnabled(module)
                    HStack(spacing: Theme.Spacing.m) {
                        Toggle("", isOn: Binding(
                            get: { isEnabled },
                            set: { _ in settings.toggleModule(module) }
                        ))
                        .labelsHidden()

                        Image(systemName: module.symbol)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(isEnabled ? Color.accentColor : Color.secondary)
                            .frame(width: 26, height: 26)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(isEnabled ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.10))
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(module.title)
                                    .fontWeight(.medium)
                                    .foregroundStyle(isEnabled ? Color.primary : Color.secondary)
                                if isSupported(module) {
                                    Text("Available")
                                        .font(.system(size: 9, weight: .semibold))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1)
                                        .background(Capsule().fill(Color.green.opacity(0.18)))
                                        .foregroundStyle(Color.green)
                                }
                            }
                            Text(module.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        // Reorder buttons (Move Up / Move Down)
                        HStack(spacing: 4) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    settings.moveModule(at: index, up: true)
                                }
                            } label: {
                                Image(systemName: "chevron.up")
                                    .font(.caption.bold())
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.borderless)
                            .disabled(index == 0)
                            .help("Move Up")

                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    settings.moveModule(at: index, up: false)
                                }
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.caption.bold())
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.borderless)
                            .disabled(index == settings.panelModuleOrder.count - 1)
                            .help("Move Down")
                        }
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                Text("Modules & Order")
            } footer: {
                FormFooter("Use the up/down arrows to reorder modules. Modules appear in this exact sequence in your menu bar panel.")
            }

            Section {
                Button("Restore Default Arrangement", action: settings.resetPanelCustomization)
            }
        }
        .settingsPaneStyle()
    }

    private func isSupported(_ module: PanelModule) -> Bool {
        guard let profile = manager.profile else { return true }
        switch module {
        case .battery:
            return manager.presentation(.battery) != .hidden
        case .noiseControl:
            return manager.presentation(.noiseControl) != .hidden && !(profile.opo?.noiseModes.isEmpty ?? true)
        case .gameMode:
            return manager.presentation(.gameMode) != .hidden
        case .equalizer:
            return manager.presentation(.equalizer) != .hidden && !(profile.opo?.equalizerPresets.isEmpty ?? true)
        case .inEarDetection:
            return profile.opo?.wearDetectionFeatureID != nil && manager.presentation(.wearDetection) != .hidden
        }
    }
}
