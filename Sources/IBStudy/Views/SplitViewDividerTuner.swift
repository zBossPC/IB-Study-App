import AppKit
import SwiftUI

/// Softens the vertical divider between the sidebar and detail columns (AppKit `NSSplitView` behind `NavigationSplitView`).
struct SplitViewDividerTuner: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        v.isHidden = true
        return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        Task { @MainActor in
            Self.apply(to: nsView)
            try? await Task.sleep(nanoseconds: 50_000_000)
            Self.apply(to: nsView)
            try? await Task.sleep(nanoseconds: 300_000_000)
            Self.apply(to: nsView)
        }
    }

    private static func apply(to nsView: NSView) {
        guard let window = nsView.window else { return }
        guard let split = findSplitView(in: window.contentView) else { return }
        split.dividerStyle = .thin
    }

    private static func findSplitView(in view: NSView?) -> NSSplitView? {
        guard let view else { return nil }
        if let s = view as? NSSplitView { return s }
        for sub in view.subviews {
            if let found = findSplitView(in: sub) { return found }
        }
        return nil
    }
}
