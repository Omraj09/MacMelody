/// Main-window destinations, grouped as in the sidebar.
enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case overview, noiseControl, equalizer, gestures
    case generalSettings, appearanceSettings, menuBarSettings, connectionCardSettings, demoSettings, aboutSettings
    case deviceInfo, compatibility, diagnostics

    static let earbuds: [SidebarItem] = [.overview, .noiseControl, .equalizer, .gestures]
    static let settings: [SidebarItem] = [
        .generalSettings,
        .appearanceSettings,
        .menuBarSettings,
        .connectionCardSettings,
        .demoSettings,
        .aboutSettings
    ]
    static let information: [SidebarItem] = [.deviceInfo, .compatibility, .diagnostics]

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "Overview"
        case .noiseControl: "Noise Control"
        case .equalizer: "Equalizer"
        case .gestures: "Touch Gestures"
        case .generalSettings: "General"
        case .appearanceSettings: "Appearance"
        case .menuBarSettings: "Menu Bar"
        case .connectionCardSettings: "Connection Card"
        case .demoSettings: "Demo Mode"
        case .aboutSettings: "About"
        case .deviceInfo: "Device Info"
        case .compatibility: "Compatibility"
        case .diagnostics: "Diagnostics"
        }
    }

    var symbol: String {
        switch self {
        case .overview: "earbuds"
        case .noiseControl: "waveform"
        case .equalizer: "slider.vertical.3"
        case .gestures: "hand.tap"
        case .generalSettings: "gearshape"
        case .appearanceSettings: "paintbrush"
        case .menuBarSettings: "menubar.rectangle"
        case .connectionCardSettings: "rectangle.on.rectangle"
        case .demoSettings: "play.rectangle"
        case .aboutSettings: "info.circle"
        case .deviceInfo: "info.circle"
        case .compatibility: "checklist"
        case .diagnostics: "stethoscope"
        }
    }
}
