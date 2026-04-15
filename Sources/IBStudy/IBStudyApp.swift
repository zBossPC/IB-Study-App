import SwiftUI
import AppKit

@main
struct IBStudyApp: App {
    @StateObject private var store    = ContentStore()
    @StateObject private var progress = ProgressStore()
    @StateObject private var aiSetup  = OllamaSetupManager()

    init() {
        DispatchQueue.main.async { NSApp.activate(ignoringOtherApps: true) }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(progress)
                .environmentObject(aiSetup)
                .task { await aiSetup.run() }
        }
        .defaultSize(width: 1040, height: 720)
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)

        // Floating AI Tutor window — opened with ⌘/ or the toolbar button.
        Window("AI Tutor", id: "ai-tutor") {
            AITutorView()
                .environmentObject(aiSetup)
                .environmentObject(progress)
        }
        .defaultSize(width: 520, height: 640)
        .windowResizability(.contentSize)

        // Menu bar extra — sparkles icon in the system menu bar.
        // Drops down a compact AI chat panel; accessible even when the main window is hidden.
        MenuBarExtra {
            MenuBarAIView()
                .environmentObject(aiSetup)
                .environmentObject(progress)
        } label: {
            Image(systemName: "sparkles")
        }
        .menuBarExtraStyle(.window)
    }
}
