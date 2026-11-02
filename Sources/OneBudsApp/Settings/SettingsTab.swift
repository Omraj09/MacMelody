enum SettingsTab: String, CaseIterable, Identifiable {
    case general, controlPanel, appearance, menuBar, connectionCard, demo, about

    var id: Self { self }

    var title: String {
        switch self {
        case .general: "General"
        case .controlPanel: "Control Panel"
        case .appearance: "Appearance"
        case .menuBar: "Menu Bar"
        case .connectionCard: "Connection Card"
        case .demo: "Demo"
        case .about: "About"
        }
    }

    var systemImage: String {
        switch self {
        case .general: "gearshape"
        case .controlPanel: "slider.horizontal.2.square.on.square"
        case .appearance: "paintbrush"
        case .menuBar: "menubar.rectangle"
        case .connectionCard: "rectangle.on.rectangle"
        case .demo: "play.rectangle"
        case .about: "info.circle"
        }
    }
}
