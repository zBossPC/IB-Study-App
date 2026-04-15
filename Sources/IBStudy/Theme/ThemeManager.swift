import SwiftUI

struct AppTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String
    let pageTop: Color
    let pageBottom: Color
    let pageMid: Color
    let accentCore: Color
    let accentGlow: Color
    let panelFill: Double
    let panelStroke: Double
}

extension AppTheme {
    static let midnight = AppTheme(
        id: "midnight", name: "Midnight", icon: "moon.stars.fill",
        pageTop: Color(red: 0.09, green: 0.13, blue: 0.22),
        pageBottom: Color(red: 0.04, green: 0.05, blue: 0.10),
        pageMid: Color(red: 0.11, green: 0.09, blue: 0.23),
        accentCore: Color(red: 0.45, green: 0.87, blue: 1.00),
        accentGlow: Color(red: 0.57, green: 0.46, blue: 1.00),
        panelFill: 0.07, panelStroke: 0.12
    )

    static let ocean = AppTheme(
        id: "ocean", name: "Ocean", icon: "water.waves",
        pageTop: Color(red: 0.04, green: 0.12, blue: 0.20),
        pageBottom: Color(red: 0.02, green: 0.06, blue: 0.12),
        pageMid: Color(red: 0.06, green: 0.14, blue: 0.24),
        accentCore: Color(red: 0.20, green: 0.72, blue: 0.90),
        accentGlow: Color(red: 0.30, green: 0.55, blue: 0.95),
        panelFill: 0.06, panelStroke: 0.10
    )

    static let aurora = AppTheme(
        id: "aurora", name: "Aurora", icon: "sparkles",
        pageTop: Color(red: 0.06, green: 0.12, blue: 0.14),
        pageBottom: Color(red: 0.04, green: 0.06, blue: 0.10),
        pageMid: Color(red: 0.08, green: 0.16, blue: 0.14),
        accentCore: Color(red: 0.30, green: 0.90, blue: 0.70),
        accentGlow: Color(red: 0.20, green: 0.75, blue: 0.85),
        panelFill: 0.06, panelStroke: 0.10
    )

    static let ember = AppTheme(
        id: "ember", name: "Ember", icon: "flame.fill",
        pageTop: Color(red: 0.18, green: 0.08, blue: 0.06),
        pageBottom: Color(red: 0.08, green: 0.04, blue: 0.04),
        pageMid: Color(red: 0.22, green: 0.10, blue: 0.08),
        accentCore: Color(red: 1.00, green: 0.55, blue: 0.25),
        accentGlow: Color(red: 1.00, green: 0.35, blue: 0.30),
        panelFill: 0.08, panelStroke: 0.12
    )

    static let lavender = AppTheme(
        id: "lavender", name: "Lavender", icon: "leaf.fill",
        pageTop: Color(red: 0.14, green: 0.10, blue: 0.22),
        pageBottom: Color(red: 0.06, green: 0.04, blue: 0.12),
        pageMid: Color(red: 0.16, green: 0.12, blue: 0.26),
        accentCore: Color(red: 0.72, green: 0.58, blue: 1.00),
        accentGlow: Color(red: 0.85, green: 0.55, blue: 0.95),
        panelFill: 0.07, panelStroke: 0.11
    )

    static let slate = AppTheme(
        id: "slate", name: "Slate", icon: "square.grid.2x2.fill",
        pageTop: Color(red: 0.12, green: 0.13, blue: 0.15),
        pageBottom: Color(red: 0.06, green: 0.06, blue: 0.08),
        pageMid: Color(red: 0.14, green: 0.15, blue: 0.17),
        accentCore: Color(red: 0.60, green: 0.70, blue: 0.82),
        accentGlow: Color(red: 0.50, green: 0.60, blue: 0.75),
        panelFill: 0.06, panelStroke: 0.09
    )

    static let allThemes: [AppTheme] = [.midnight, .ocean, .aurora, .ember, .lavender, .slate]
}

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @AppStorage("ibstudy.themeId") private var storedThemeId = "midnight"

    @Published var current: AppTheme = .midnight

    init() {
        current = AppTheme.allThemes.first { $0.id == UserDefaults.standard.string(forKey: "ibstudy.themeId") } ?? .midnight
    }

    func apply(_ theme: AppTheme) {
        withAnimation(.easeInOut(duration: 0.4)) {
            current = theme
            storedThemeId = theme.id
        }
    }

    var pageGradient: LinearGradient {
        LinearGradient(
            colors: [current.pageTop, current.pageMid, current.pageBottom],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}
