import AppKit
import Observation
import OneBudsCore
import SwiftUI

/// Observable state driving the menu bar popover open/close animation.
@MainActor
final class PopoverPresentationState: ObservableObject {
    @Published var isOpen: Bool = false
}

/// Manages the macOS menu bar status item and its borderless, 100% transparent floating popover panel.
/// Provides smooth opening/closing scale+fade transitions and downward-only expansion.
@MainActor
final class MenuBarController: NSObject {
    private let model: AppModel
    private let manager: DeviceManager
    private let settings: AppSettings
    private let presentationState = PopoverPresentationState()
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
        if presentationState.isOpen {
            hidePopover()
        } else {
            showPopover()
        }
    }

    private func setupPanel() -> MenuBarPopoverPanel {
        let panel = MenuBarPopoverPanel(
            model: model,
            manager: manager,
            settings: settings,
            presentationState: presentationState
        ) { [weak self] in
            self?.hidePopover()
        }
        if let hostingView = panel.contentView as? MenuBarHostingView<PopoverContainerView> {
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

        presentationState.isOpen = false
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

        // Smooth opening bloom animation downward from menu bar icon
        withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
            presentationState.isOpen = true
        }

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

        // Anchor top edge permanently below menu bar:
        // Any change in height extends solely downwards!
        let top = buttonFrame.minY - 4
        let y = top - size.height

        let newFrame = NSRect(x: x, y: y, width: size.width, height: size.height)
        guard panel.frame != newFrame else { return }

        if animate {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.24
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
        withAnimation(.easeOut(duration: 0.15)) {
            presentationState.isOpen = false
        }
        stopEventMonitors()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self, !self.presentationState.isOpen else { return }
            self.panel?.orderOut(nil)
        }
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

/// Outer container pinning PopoverView to the top edge and driving scale+fade entrance/exit animations.
struct PopoverContainerView: View {
    @ObservedObject var presentationState: PopoverPresentationState
    let model: AppModel
    let manager: DeviceManager
    let settings: AppSettings

    var body: some View {
        VStack(spacing: 0) {
            PopoverView()
                .environment(model)
                .environment(manager)
                .environment(\.visualStyle, settings.visualStyle)
                .environment(settings)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .scaleEffect(presentationState.isOpen ? 1.0 : 0.93, anchor: .top)
        .opacity(presentationState.isOpen ? 1.0 : 0.0)
        .offset(y: presentationState.isOpen ? 0 : -8)
    }
}

/// A floating, non-activating borderless NSPanel that has 100% transparent backing and no rectangular chrome.
final class MenuBarPopoverPanel: NSPanel {
    private let onDismiss: () -> Void

    init(
        model: AppModel,
        manager: DeviceManager,
        settings: AppSettings,
        presentationState: PopoverPresentationState,
        onDismiss: @escaping () -> Void
    ) {
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

        let container = PopoverContainerView(
            presentationState: presentationState,
            model: model,
            manager: manager,
            settings: settings
        )

        self.contentView = MenuBarHostingView(rootView: container)
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
    private var resizeTask: Task<Void, Never>?

    override func layout() {
        super.layout()
        let size = fittingSize
        guard size.width > 0, size.height > 0 else { return }
        guard abs(size.height - lastHeight) > 1.5 else { return }

        resizeTask?.cancel()
        resizeTask = Task { @MainActor [weak self] in
            // Small debounce to let sub-frame interpolations settle into target size
            try? await Task.sleep(nanoseconds: 16_000_000) // ~1 frame (16ms)
            guard !Task.isCancelled, let self else { return }
            let finalSize = self.fittingSize
            if abs(finalSize.height - self.lastHeight) > 1.0 {
                self.lastHeight = finalSize.height
                self.onFittingSizeChange?(finalSize)
            }
        }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
