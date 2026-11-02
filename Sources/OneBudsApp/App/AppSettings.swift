import Foundation
import Observation
import OneBudsCore

/// User preferences, persisted locally in UserDefaults.
@MainActor
@Observable
final class AppSettings {
    static let demoModels = DeviceRegistry.all.filter(\.allowsControlSession)

    private let defaults: UserDefaults

    var appearance: AppAppearance {
        didSet {
            defaults.set(appearance.rawValue, forKey: "appearance")
            appearance.apply()
        }
    }

    var visualStyle: VisualStyle {
        didSet { defaults.set(visualStyle.rawValue, forKey: "visualStyle") }
    }

    var showBatteryInMenuBar: Bool {
        didSet { defaults.set(showBatteryInMenuBar, forKey: "showBatteryInMenuBar") }
    }

    /// Show the floating connection card when earbuds connect.
    var showConnectionCard: Bool {
        didSet { defaults.set(showConnectionCard, forKey: "showConnectionCard") }
    }

    /// How long the connection card stays up on its own.
    var cardDuration: CardDuration {
        didSet { defaults.set(cardDuration.rawValue, forKey: "cardDuration") }
    }

    /// Which artwork the connection card may use (always within what is installed).
    var cardArtworkStyle: CardArtworkStyle {
        didSet { defaults.set(cardArtworkStyle.rawValue, forKey: "cardArtworkStyle") }
    }

    /// Gentle sway of a 3D model on the card. Reduce Motion always holds it still.
    var animateCardModel: Bool {
        didSet { defaults.set(animateCardModel, forKey: "animateCardModel") }
    }

    /// Ordered list of modules in the menu bar control panel.
    var panelModuleOrder: [PanelModule] {
        didSet {
            let ids = panelModuleOrder.map(\.rawValue)
            defaults.set(ids, forKey: "panelModuleOrder")
        }
    }

    /// Set of enabled modules in the menu bar control panel.
    var enabledPanelModules: Set<PanelModule> {
        didSet {
            let ids = Array(enabledPanelModules.map(\.rawValue))
            defaults.set(ids, forKey: "enabledPanelModules")
        }
    }

    /// Layout orientation and style for the control panel.
    var panelOrientation: PanelOrientation {
        didSet { defaults.set(panelOrientation.rawValue, forKey: "panelOrientation") }
    }

    private(set) var demoMode: Bool {
        didSet { defaults.set(demoMode, forKey: "demoMode") }
    }

    /// Which model Demo mode simulates.
    private(set) var demoModelID: String {
        didSet { defaults.set(demoModelID, forKey: "demoModelID") }
    }

    var demoProfile: DeviceProfile {
        Self.demoModels.first { $0.id == demoModelID } ?? DeviceRegistry.onePlusBuds3
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        appearance = AppAppearance(rawValue: defaults.string(forKey: "appearance") ?? "") ?? .system
        visualStyle = VisualStyle(rawValue: defaults.string(forKey: "visualStyle") ?? "") ?? .glass
        showBatteryInMenuBar = defaults.object(forKey: "showBatteryInMenuBar") as? Bool ?? true
        showConnectionCard = defaults.object(forKey: "showConnectionCard") as? Bool ?? true
        cardDuration = CardDuration(rawValue: defaults.string(forKey: "cardDuration") ?? "") ?? .standard
        cardArtworkStyle = CardArtworkStyle(rawValue: defaults.string(forKey: "cardArtworkStyle") ?? "") ?? .automatic
        animateCardModel = defaults.object(forKey: "animateCardModel") as? Bool ?? true

        // Panel customization
        if let savedOrder = defaults.stringArray(forKey: "panelModuleOrder") {
            var order = savedOrder.compactMap { PanelModule(rawValue: $0) }
            for m in PanelModule.allCases where !order.contains(m) {
                order.append(m)
            }
            panelModuleOrder = order.isEmpty ? PanelModule.allCases : order
        } else {
            panelModuleOrder = [.battery, .noiseControl, .gameMode, .equalizer, .inEarDetection, .spatialAudio]
        }

        if let savedEnabled = defaults.stringArray(forKey: "enabledPanelModules") {
            enabledPanelModules = Set(savedEnabled.compactMap { PanelModule(rawValue: $0) })
        } else {
            enabledPanelModules = [.battery, .noiseControl, .gameMode, .equalizer]
        }

        panelOrientation = PanelOrientation(rawValue: defaults.string(forKey: "panelOrientation") ?? "") ?? .stacked

        demoMode = defaults.bool(forKey: "demoMode")
        demoModelID = defaults.string(forKey: "demoModelID") ?? DeviceRegistry.onePlusBuds3.id
    }

    func setDemoMode(_ value: Bool) { demoMode = value }
    func setDemoModel(_ id: String) { demoModelID = id }

    func isModuleEnabled(_ module: PanelModule) -> Bool {
        enabledPanelModules.contains(module)
    }

    func toggleModule(_ module: PanelModule) {
        if enabledPanelModules.contains(module) {
            // Keep at least one module enabled
            if enabledPanelModules.count > 1 {
                enabledPanelModules.remove(module)
            }
        } else {
            enabledPanelModules.insert(module)
        }
    }

    func moveModule(at index: Int, up: Bool) {
        let targetIndex = up ? index - 1 : index + 1
        guard targetIndex >= 0 && targetIndex < panelModuleOrder.count else { return }
        panelModuleOrder.swapAt(index, targetIndex)
    }

    func resetPanelCustomization() {
        panelModuleOrder = [.battery, .noiseControl, .gameMode, .equalizer, .inEarDetection, .spatialAudio]
        enabledPanelModules = [.battery, .noiseControl, .gameMode, .equalizer]
        panelOrientation = .stacked
    }
}
