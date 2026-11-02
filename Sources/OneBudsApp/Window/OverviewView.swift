import OneBudsCore
import SwiftUI

struct OverviewView: View {
    @Environment(AppModel.self) private var model
    @Environment(DeviceManager.self) private var manager

    var body: some View {
        Form {
            Section {
                DeviceHeroCard()
            }

            if manager.connection.isConnected {
                if manager.presentation(.battery) != .hidden {
                    Section {
                        if let battery = manager.battery, !battery.isEmpty {
                            BatteryRow(battery: battery, large: true)
                                .padding(.vertical, Theme.Spacing.s)
                        } else {
                            Text("The earbuds haven't reported battery levels yet.")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        SectionHeader(title: "Battery", presentation: manager.presentation(.battery))
                    }
                }
                if manager.presentation(.noiseControl) != .hidden {
                    Section {
                        NoiseModeSelector(large: true)
                            .padding(.vertical, Theme.Spacing.s - 2)
                    } header: {
                        SectionHeader(title: "Noise Control", presentation: manager.presentation(.noiseControl))
                    }
                }
                FeatureTogglesSection()

                Section {
                    Button {
                        model.selection = .panelCustomization
                    } label: {
                        HStack {
                            Label("Customize Menu Bar Panel…", systemImage: "slider.horizontal.2.square.on.square")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } footer: {
                    Text("Configure which controls appear in the menu bar panel and customize their layout orientation.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = manager.lastError {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }
        }
        .screenFormStyle()
        .overlay {
            if !manager.connection.isConnected {
                ConnectionStateView()
                    .padding(.top, 120)
            }
        }
        .animateState(value: manager.connection.isConnected)
    }
}
