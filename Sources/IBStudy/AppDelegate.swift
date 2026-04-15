import AppKit
import Sparkle
import SwiftUI

// MARK: - Sparkle "Check for Updates"

private struct CheckForUpdatesKey: EnvironmentKey {
    static let defaultValue: @Sendable () -> Void = {}
}

extension EnvironmentValues {
    var checkForUpdates: @Sendable () -> Void {
        get { self[CheckForUpdatesKey.self] }
        set { self[CheckForUpdatesKey.self] = newValue }
    }
}

/// Owns Sparkle's standard updater (background checks + UI). Created once at launch.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {
    /// Lazy so `self` can be the `SPUUpdaterDelegate` without touching `self` before `init` completes.
    private lazy var updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: self,
        userDriverDelegate: nil
    )

    func feedURLString(for updater: SPUUpdater) -> String? {
        "https://raw.githubusercontent.com/zBossPC/IB-Study-App/main/docs/appcast.xml"
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
