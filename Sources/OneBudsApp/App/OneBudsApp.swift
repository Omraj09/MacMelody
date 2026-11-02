import OneBudsCore
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

@main
struct OneBudsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var model: AppModel

    init() {
        let model = AppModel()
        _model = State(initialValue: model)
        model.start()
    }

    var body: some Scene {
        Window("MacMelody", id: AppModel.mainWindowID) {
            MainWindow()
                .environment(model)
                .environment(model.manager)
                .environment(\.visualStyle, model.settings.visualStyle)
        }
        .defaultSize(width: 880, height: 620)
        .windowResizability(.contentMinSize)
        .commands {
            EarbudsCommands(model: model)
        }

        Settings {
            SettingsView()
                .environment(model)
                .environment(model.manager)
                .environment(\.visualStyle, model.settings.visualStyle)
        }
    }
}
