import AppKit
import SwiftUI

/// Softens the vertical divider between the sidebar and detail columns (AppKit `NSSplitView` behind `NavigationSplitView`).
struct SplitViewDividerTuner: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        v.isHidden = true
        return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        Self.apply(to: nsView)
        context.coordinator.scheduleDebouncedApply(to: nsView)
    }

    /// One immediate pass plus a single debounced follow-up after layout/sidebar animation settles.
    /// Avoids stacking `Task` + repeated `sleep` on every `updateNSView`, which stutters split resizing.
    @MainActor
    final class Coordinator {
        private var pending: DispatchWorkItem?

        func scheduleDebouncedApply(to nsView: NSView) {
            pending?.cancel()
            let work = DispatchWorkItem { [weak self] in
                SplitViewDividerTuner.apply(to: nsView)
                self?.pending = nil
            }
            pending = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
        }
    }

    private static func apply(to nsView: NSView) {
        guard let window = nsView.window else { return }
        for split in findAllSplitViews(in: window.contentView) {
            split.dividerStyle = .thin
            softenDividers(in: split)
        }
    }

    /// Hides the bright default split divider (reads as a white line on dark gradients).
    private static func softenDividers(in split: NSSplitView) {
        for sub in split.subviews {
            let r = sub.bounds
            guard r.width > 0, r.height > 0 else { continue }
            if r.width <= 12, r.height >= 48 {
                sub.wantsLayer = true
                sub.layer?.backgroundColor = NSColor.clear.cgColor
                sub.alphaValue = 0
            }
        }
    }

    private static func findAllSplitViews(in view: NSView?) -> [NSSplitView] {
        guard let view else { return [] }
        var out: [NSSplitView] = []
        if let s = view as? NSSplitView { out.append(s) }
        for sub in view.subviews {
            out.append(contentsOf: findAllSplitViews(in: sub))
        }
        return out
    }
}
