import AppKit
import Sparkle
import SwiftUI

// MARK: - Sparkle “Check for Updates”

private struct CheckForUpdatesKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var checkForUpdates: () -> Void {
        get { self[CheckForUpdatesKey.self] }
        set { self[CheckForUpdatesKey.self] = newValue }
    }
}

/// Owns Sparkle’s standard updater (background checks + UI). Created once at launch.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
