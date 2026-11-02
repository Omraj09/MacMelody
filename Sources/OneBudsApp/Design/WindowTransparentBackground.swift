import AppKit
import SwiftUI

/// Configures the hosting NSWindow to be completely transparent so that custom continuous-corner
/// Liquid Glass surfaces can render without being clipped by the system rectangular window frame.
struct WindowTransparentBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = WindowConfiguringView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? WindowConfiguringView)?.applyTransparency()
    }

    final class WindowConfiguringView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            applyTransparency()
        }

        func applyTransparency() {
            DispatchQueue.main.async { [weak self] in
                guard let window = self?.window else { return }
                window.isOpaque = false
                window.backgroundColor = .clear
                window.hasShadow = true
                if let contentView = window.contentView {
                    contentView.wantsLayer = true
                    contentView.layer?.backgroundColor = NSColor.clear.cgColor
                    for subview in contentView.subviews {
                        subview.wantsLayer = true
                        subview.layer?.backgroundColor = NSColor.clear.cgColor
                    }
                }
                window.invalidateShadow()
            }
        }
    }
}
