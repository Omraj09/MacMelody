import AppKit
import SwiftUI

struct PopoverFooter: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        HStack {
            Button("More Settings…", systemImage: "gearshape", action: showMoreSettings)
                .keyboardShortcut(",")
            Spacer()
            Button("Quit", systemImage: "power", action: quit)
                .keyboardShortcut("q")
        }
        .buttonStyle(.borderless)
        .labelStyle(.titleAndIcon)
        .font(.callout)
    }

    private func showMoreSettings() {
        model.selection = .generalSettings
        openWindow(id: AppModel.mainWindowID)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func quit() { NSApp.terminate(nil) }
}
