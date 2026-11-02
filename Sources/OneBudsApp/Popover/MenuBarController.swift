import AppKit
import Observation
import OneBudsCore
import SwiftUI

/// Manages the macOS menu bar status item and its borderless, 100% transparent floating popover panel.
/// This replaces MenuBarExtraWindow to completely eliminate the system rectangular window border and glitchy background.
@MainActor
final class MenuBarController: NSObject {
    private let model: AppModel
    private let manager: DeviceManager
    private let settings: AppSettings
    private var statusItem: NSStatusItem?
    private var panel: MenuBarPopoverPanel?
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?

    init(model: AppModel, manager: DeviceManager, settings: AppSettings) {
        self.model = model
        self.manager = manager
        self.settings = settings
        super.init()
        setupStatusItem()
        startObserving()
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        self.statusItem = item
        updateStatusItemButton()
    }

    private func startObserving() {
        withObservationTracking {
            _ = manager.connection
            _ = manager.battery
            _ = settings.showBatteryInMenuBar
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.updateStatusItemButton()
                self?.startObserving()
            }
        }
    }

    private func updateStatusItemButton() {
        guard let button = statusItem?.button else { return }

        let symbol: String
        switch manager.connection {
        case .connected:
            symbol = "earbuds"
        case .unauthorized, .failed, .bluetoothOff, .bluetoothUnsupported:
            symbol = "exclamationmark.triangle"
        default:
            symbol = "earbuds.case"
        }

        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "MacMelody")
        button.imagePosition = .imageLeading

        if settings.showBatteryInMenuBar, manager.connection.isConnected, let bud = manager.battery?.lowestBud {
            button.title = " \(bud.percent)%"
        } else {
            button.title = ""
        }
    }

    @objc private func statusItemClicked(_ sender: Any?) {
        guard let panel else {
            showPopover()
            return
        }
        if panel.isVisible {
            hidePopover()
        } else {
            showPopover()
        }
    }

    func showPopover() {
        guard let button = statusItem?.button, let buttonWindow = button.window else { return }
        let screen = buttonWindow.screen ?? NSScreen.main ?? NSScreen.screens.first!

        let panel: MenuBarPopoverPanel
        if let existing = self.panel {
            panel = existing
        } else {
            let created = MenuBarPopoverPanel(model: model, manager: manager, settings: settings) { [weak self] in
                self?.hidePopover()
            }
            self.panel = created
            panel = created
        }

        let fittingSize = panel.contentView?.fittingSize ?? CGSize(width: Theme.Size.popoverWidth + 32, height: 440)
        let buttonFrame = buttonWindow.convertToScreen(button.bounds)

        var x = buttonFrame.midX - (fittingSize.width / 2)
        let minX = screen.visibleFrame.minX + 8
        let maxX = screen.visibleFrame.maxX - fittingSize.width - 8
        x = max(minX, min(x, maxX))

        let y = buttonFrame.minY - fittingSize.height + 10 // Inset to sit right under menu bar
        panel.setFrame(NSRect(x: x, y: y, width: fittingSize.width, height: fittingSize.height), display: true)
        panel.makeKeyAndOrderFront(nil)

        startEventMonitors()
    }

    func hidePopover() {
        panel?.orderOut(nil)
        stopEventMonitors()
    }

    private func startEventMonitors() {
        stopEventMonitors()
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.hidePopover()
        }
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape
                self?.hidePopover()
                return nil
            }
            return event
        }
    }

    private func stopEventMonitors() {
        if let globalEventMonitor {
            NSEvent.removeMonitor(globalEventMonitor)
            self.globalEventMonitor = nil
        }
        if let localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
            self.localEventMonitor = nil
        }
    }
}

/// A floating, non-activating borderless NSPanel that has 100% transparent backing and no rectangular chrome.
final class MenuBarPopoverPanel: NSPanel {
    private let onDismiss: () -> Void

    init(model: AppModel, manager: DeviceManager, settings: AppSettings, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = .popUpMenu
        self.isFloatingPanel = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.animationBehavior = .none

        let rootView = PopoverView()
            .environment(model)
            .environment(manager)
            .environment(\.visualStyle, settings.visualStyle)
            .environment(settings)

        self.contentView = MenuBarHostingView(rootView: AnyView(rootView))
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect { frameRect }

    override func cancelOperation(_ sender: Any?) {
        onDismiss()
    }
}

private final class MenuBarHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
