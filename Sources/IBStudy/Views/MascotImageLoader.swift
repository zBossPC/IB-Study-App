import AppKit
import Foundation

/// Loads the mascot PNG from whichever bundle actually has it (SwiftPM dev bundle vs flat `Resources/` in a shipped `.app`).
enum MascotImageLoader {
    private static let raster: NSImage? = {
        let name = "MascotGuide"
        let bundles: [Bundle] = [.main, Bundle.module]
        for bundle in bundles {
            if let url = bundle.url(forResource: name, withExtension: "png"),
               let img = NSImage(contentsOf: url), img.size.width > 2 {
                return img
            }
            if let img = bundle.image(forResource: NSImage.Name(name)), img.size.width > 2 {
                return img
            }
        }
        if let img = NSImage(named: NSImage.Name(name)), img.size.width > 2 {
            return img
        }
        return nil
    }()

    static func rasterImage() -> NSImage? { raster }
}
