import SwiftUI
import AppKit

@main
struct IBStudyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @StateObject private var store    = ContentStore()
    @StateObject private var progress = ProgressStore()
    @StateObject private var aiSetup  = OllamaSetupManager()
    @StateObject private var themeManager = ThemeManager.shared

    init() {
        DispatchQueue.main.async { NSApp.activate(ignoringOtherApps: true) }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(progress)
                .environmentObject(aiSetup)
                .environmentObject(themeManager)
                .environment(\.checkForUpdates) {
                    appDelegate.checkForUpdates()
                }
                .task { await aiSetup.run() }
        }
        .defaultSize(width: 1040, height: 720)
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)

        Window("AI Tutor", id: "ai-tutor") {
            AITutorView()
                .environmentObject(aiSetup)
                .environmentObject(progress)
                .environmentObject(themeManager)
        }
        .defaultSize(width: 520, height: 640)
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarAIView()
                .environmentObject(aiSetup)
                .environmentObject(progress)
                .environmentObject(themeManager)
        } label: {
            Image(systemName: "sparkles")
        }
        .menuBarExtraStyle(.window)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates…") {
                    appDelegate.checkForUpdates()
                }
                .keyboardShortcut("U", modifiers: [.command, .shift])
            }
        }
    }
}
