import AppKit
import os
import SwiftUI

private let logger = Logger(subsystem: "com.local.macmelody", category: "window")

/// Configures the hosting NSWindow to be completely transparent and rounded to match the Liquid Glass
/// panel so that no outer rectangular window border or grey corners are visible.
struct WindowTransparentBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = WindowConfiguringView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? WindowConfiguringView)?.applyTransparency()
    }

    final class WindowConfiguringView: NSView {
        private var observers: [NSObjectProtocol] = []

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            setupObservers()
            applyTransparency()
        }

        private func setupObservers() {
            for obs in observers { NotificationCenter.default.removeObserver(obs) }
            observers.removeAll()
            guard let window = self.window else { return }
            let nc = NotificationCenter.default
            observers.append(nc.addObserver(forName: NSWindow.didBecomeKeyNotification, object: window, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.applyTransparency()
                }
            })
            observers.append(nc.addObserver(forName: NSWindow.didUpdateNotification, object: window, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.applyTransparency()
                }
            })
        }

        override func viewWillDraw() {
            super.viewWillDraw()
            applyTransparency()
        }

        func applyTransparency() {
            guard let window = self.window else { return }

            if window.isOpaque {
                window.isOpaque = false
            }
            if window.backgroundColor != .clear {
                window.backgroundColor = .clear
            }

            let radius: CGFloat = Theme.Radius.popover

            if let frameView = window.contentView?.superview {
                if !frameView.wantsLayer { frameView.wantsLayer = true }
                if let layer = frameView.layer {
                    if layer.backgroundColor != NSColor.clear.cgColor {
                        layer.backgroundColor = NSColor.clear.cgColor
                    }
                    if layer.cornerRadius != radius {
                        layer.cornerRadius = radius
                        layer.cornerCurve = .continuous
                        layer.masksToBounds = true
                    }
                }
            }

            if let contentView = window.contentView {
                if !contentView.wantsLayer { contentView.wantsLayer = true }
                if let layer = contentView.layer {
                    if layer.backgroundColor != NSColor.clear.cgColor {
                        layer.backgroundColor = NSColor.clear.cgColor
                    }
                    if layer.cornerRadius != radius {
                        layer.cornerRadius = radius
                        layer.cornerCurve = .continuous
                        layer.masksToBounds = true
                    }
                }

                // Hide SwiftUI's default rectangular background views in MenuBarExtraHostingView
                for subview in contentView.subviews {
                    if subview.subviews.isEmpty, subview.layer?.backgroundColor != nil {
                        if !subview.isHidden {
                            subview.isHidden = true
                        }
                        if subview.layer?.backgroundColor != NSColor.clear.cgColor {
                            subview.layer?.backgroundColor = NSColor.clear.cgColor
                            subview.layer?.opacity = 0
                        }
                    }
                }
            }

            if !window.hasShadow {
                window.hasShadow = true
            }
            window.invalidateShadow()
        }
    }
}
