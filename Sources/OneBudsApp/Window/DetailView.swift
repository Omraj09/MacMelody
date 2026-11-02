import SwiftUI

/// Routes a sidebar destination to its screen.
struct DetailView: View {
    let destination: SidebarItem

    var body: some View {
        switch destination {
        case .overview: OverviewView()
        case .noiseControl: NoiseControlView()
        case .equalizer: EqualizerView()
        case .gestures: GesturesView()
        case .generalSettings: GeneralSettingsPane()
        case .panelCustomization: PanelCustomizationPane()
        case .appearanceSettings: AppearanceSettingsPane()
        case .menuBarSettings: MenuBarSettingsPane()
        case .connectionCardSettings: ConnectionCardSettingsPane()
        case .demoSettings: DemoSettingsPane()
        case .aboutSettings: AboutSettingsPane()
        case .deviceInfo: DeviceInfoView()
        case .compatibility: CompatibilityView()
        case .diagnostics: DiagnosticsView()
        }
    }
}
