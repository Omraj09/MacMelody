import AppKit
import OneBudsCore
import SwiftUI

struct MainWindow: View {
    @Environment(AppModel.self) private var model
    @Environment(DeviceManager.self) private var manager

    private var destination: SidebarItem { model.selection ?? .overview }

    var body: some View {
        NavigationSplitView {
            MainSidebar()
        } detail: {
            DetailView(destination: destination)
                .frame(minWidth: Theme.Size.detailMinWidth, minHeight: Theme.Size.detailMinHeight)
                .navigationTitle(destination.title)
                .navigationSubtitle(manager.earbuds?.name ?? "")
                .toolbar { MainToolbar(manager: manager) }
                .windowGlass()
        }
        .background(MainWindowTransparentBackground())
        .onAppear(perform: AppActivationPolicy.enter)
        .onDisappear(perform: AppActivationPolicy.leave)
    }
}

private struct MainWindowTransparentBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            guard let window = view?.window else { return }
            window.isOpaque = false
            window.backgroundColor = .clear
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { [weak nsView] in
            guard let window = nsView?.window else { return }
            if window.isOpaque { window.isOpaque = false }
            if window.backgroundColor != .clear { window.backgroundColor = .clear }
        }
    }
}
