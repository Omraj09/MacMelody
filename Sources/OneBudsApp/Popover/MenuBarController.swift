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

    private func setupPanel() -> MenuBarPopoverPanel {
        let panel = MenuBarPopoverPanel(model: model, manager: manager, settings: settings) { [weak self] in
            self?.hidePopover()
        }
        if let hostingView = panel.contentView as? MenuBarHostingView<AnyView> {
            hostingView.onFittingSizeChange = { [weak self] newSize in
                self?.updatePanelFrame(for: newSize, animate: true)
            }
        }
        return panel
    }

    func showPopover() {
        guard let button = statusItem?.button, let buttonWindow = button.window else { return }
        let screen = buttonWindow.screen ?? NSScreen.main ?? NSScreen.screens.first!

        let panel = self.panel ?? setupPanel()
        self.panel = panel

        panel.layoutIfNeeded()
        let size = panel.contentView?.fittingSize ?? CGSize(width: Theme.Size.popoverWidth, height: 420)
        let buttonFrame = buttonWindow.convertToScreen(button.bounds)

        var x = buttonFrame.midX - (size.width / 2)
        let minX = screen.visibleFrame.minX + 8
        let maxX = screen.visibleFrame.maxX - size.width - 8
        x = max(minX, min(x, maxX))

        let top = buttonFrame.minY - 4
        let y = top - size.height

        panel.setFrame(NSRect(x: x, y: y, width: size.width, height: size.height), display: true)
        panel.invalidateShadow()
        panel.makeKeyAndOrderFront(nil)

        startEventMonitors()
    }

    func updatePanelFrame(for size: CGSize, animate: Bool = true) {
        guard let panel, panel.isVisible, let button = statusItem?.button, let buttonWindow = button.window else { return }
        let screen = buttonWindow.screen ?? NSScreen.main ?? NSScreen.screens.first!
        let buttonFrame = buttonWindow.convertToScreen(button.bounds)

        var x = buttonFrame.midX - (size.width / 2)
        let minX = screen.visibleFrame.minX + 8
        let maxX = screen.visibleFrame.maxX - size.width - 8
        x = max(minX, min(x, maxX))

        let top = buttonFrame.minY - 4
        let y = top - size.height

        let newFrame = NSRect(x: x, y: y, width: size.width, height: size.height)
        guard panel.frame != newFrame else { return }

        if animate {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                context.allowsImplicitAnimation = true
                panel.animator().setFrame(newFrame, display: true)
            } completionHandler: {
                MainActor.assumeIsolated {
                    panel.invalidateShadow()
                }
            }
        } else {
            panel.setFrame(newFrame, display: true)
            panel.invalidateShadow()
        }
    }

    func hidePopover() {
        panel?.orderOut(nil)
        stopEventMonitors()
    }

    private func startEventMonitors() {
        stopEventMonitors()
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self, let button = self.statusItem?.button, let buttonWindow = button.window else {
                self?.hidePopover()
                return
            }
            let clickLocation = NSEvent.mouseLocation
            let buttonFrame = buttonWindow.convertToScreen(button.bounds)
            if !buttonFrame.contains(clickLocation) {
                self.hidePopover()
            }
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
        self.hasShadow = true
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

final class MenuBarHostingView<Content: View>: NSHostingView<Content> {
    var onFittingSizeChange: ((CGSize) -> Void)?
    private var lastHeight: CGFloat = 0

    override func layout() {
        super.layout()
        let size = fittingSize
        if size.width > 0 && size.height > 0 && abs(size.height - lastHeight) > 1 {
            lastHeight = size.height
            onFittingSizeChange?(size)
        }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
