import SwiftUI

enum GlassTheme {
    static let cornerRadius: CGFloat = 24
    static let cornerSmall: CGFloat = 16
    static let heroRadius: CGFloat = 30
    static let strokeOpacity: Double = 0.14

    static let pageTop = Color(red: 0.09, green: 0.13, blue: 0.22)
    static let pageBottom = Color(red: 0.04, green: 0.05, blue: 0.10)
    static let panelTop = Color.white.opacity(0.22)
    static let panelBottom = Color.white.opacity(0.08)
    static let mascotCore = Color(red: 0.45, green: 0.87, blue: 1.00)
    static let mascotGlow = Color(red: 0.57, green: 0.46, blue: 1.00)
    static let xpColor = Color(red: 0.98, green: 0.84, blue: 0.26)
    static let streakColor = Color(red: 1.00, green: 0.46, blue: 0.29)
    static let successColor = Color(red: 0.23, green: 0.80, blue: 0.50)

    static let pageGradient = LinearGradient(
        colors: [
            pageTop,
            Color(red: 0.11, green: 0.09, blue: 0.23),
            pageBottom
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.30),
            Color(red: 0.55, green: 0.77, blue: 1.00).opacity(0.22),
            Color(red: 0.57, green: 0.42, blue: 1.00).opacity(0.20)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let xpGradient = LinearGradient(
        colors: [xpColor, Color.orange, Color(red: 1.00, green: 0.58, blue: 0.28)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let streakGradient = LinearGradient(
        colors: [Color(red: 1.00, green: 0.74, blue: 0.25), streakColor, Color.pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mascotGradient = LinearGradient(
        colors: [mascotCore, mascotGlow, Color.white],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func sectionColor(_ id: String) -> Color {
        switch id {
        case "production":               return Color(red: 0.23, green: 0.64, blue: 1.00)
        case "short-run-costs":          return Color(red: 1.00, green: 0.61, blue: 0.21)
        case "cost-revenue-profit":      return Color(red: 0.23, green: 0.82, blue: 0.50)
        case "long-run-costs":           return Color(red: 0.63, green: 0.47, blue: 1.00)
        case "perfect-competition":      return Color(red: 0.18, green: 0.83, blue: 0.81)
        case "monopoly":                 return Color(red: 1.00, green: 0.38, blue: 0.43)
        case "monopolistic-competition": return Color(red: 0.49, green: 0.53, blue: 1.00)
        case "static-lesson1":           return Color(red: 1.00, green: 0.83, blue: 0.23)
        case "static-lesson2":           return Color(red: 1.00, green: 0.60, blue: 0.24)
        case "static-lesson3":           return Color(red: 1.00, green: 0.44, blue: 0.40)
        case "static-lesson4":           return Color(red: 0.66, green: 0.47, blue: 1.00)
        default:                         return Color.accentColor
        }
    }

    static func sectionGradient(_ id: String) -> LinearGradient {
        let base = sectionColor(id)
        return LinearGradient(
            colors: [
                base.opacity(0.95),
                base.opacity(0.72),
                base.opacity(0.45)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func sectionTint(_ id: String) -> Color {
        sectionColor(id).opacity(0.20)
    }

    static func sectionGlow(_ id: String) -> Color {
        sectionColor(id).opacity(0.45)
    }

    static func sectionIcon(_ id: String) -> String {
        switch id {
        case "production":               return "chart.line.uptrend.xyaxis"
        case "short-run-costs":          return "dollarsign.circle.fill"
        case "cost-revenue-profit":      return "sparkles.square.filled.on.square"
        case "long-run-costs":           return "arrow.up.right.circle.fill"
        case "perfect-competition":      return "target"
        case "monopoly":                 return "crown.fill"
        case "monopolistic-competition": return "seal.fill"
        case "static-lesson1":           return "atom"
        case "static-lesson2":           return "sparkles"
        case "static-lesson3":           return "arrow.left.and.right.circle.fill"
        case "static-lesson4":           return "bolt.fill"
        default:                         return "book.closed.fill"
        }
    }
}

struct PlayfieldBackground: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack {
            themeManager.pageGradient
            RadialGradient(
                colors: [themeManager.current.accentCore.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 40,
                endRadius: 380
            )
            .offset(x: -120, y: -80)
            RadialGradient(
                colors: [themeManager.current.accentGlow.opacity(0.16), .clear],
                center: .topTrailing,
                startRadius: 30,
                endRadius: 400
            )
            .offset(x: 140, y: -60)
            LinearGradient(
                colors: [Color.white.opacity(0.05), .clear, Color.black.opacity(0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

struct GlassPanel: ViewModifier {
    var tint: Color = .white
    var glow: Color = .clear
    var radius: CGFloat = GlassTheme.cornerRadius
    var padding: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.07),
                                tint.opacity(0.05),
                                Color.black.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.06),
                                        tint.opacity(0.05),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                tint.opacity(0.14),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

struct GamePrimaryButtonStyle: ButtonStyle {
    var tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                tint.opacity(configuration.isPressed ? 0.82 : 1.0),
                                tint.opacity(configuration.isPressed ? 0.58 : 0.80)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(Color.white.opacity(0.24), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

struct GameSecondaryButtonStyle: ButtonStyle {
    var tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.opacity(configuration.isPressed ? 0.20 : 0.12))
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(tint.opacity(0.30), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

struct GameCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct SectionBadge: View {
    let sectionId: String
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.36, style: .continuous)
                .fill(GlassTheme.sectionGradient(sectionId))
            RoundedRectangle(cornerRadius: size * 0.36, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            Image(systemName: GlassTheme.sectionIcon(sectionId))
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

struct StatChip: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.16))
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(tint)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline.weight(.bold))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassPanel(tint: tint, glow: tint)
    }
}

struct SectionStatusPill: View {
    let title: String
    let tint: Color
    var emphasized = false

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(emphasized ? .white : tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(emphasized ? tint : tint.opacity(0.12))
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(tint.opacity(emphasized ? 0 : 0.28), lineWidth: 1)
            )
    }
}

struct GameProgressBar: View {
    let progress: Double
    var tint: Color = GlassTheme.mascotCore
    var height: CGFloat = 10
    var showGlow = true

    private var clamped: Double { min(max(progress, 0), 1) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.10))
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.72), Color.white.opacity(0.92)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(height, geo.size.width * clamped))
            }
        }
        .frame(height: height)
    }
}

extension View {
    func glassPanel(
        tint: Color = .white,
        glow: Color = .clear,
        radius: CGFloat = GlassTheme.cornerRadius,
        padding: CGFloat = 0
    ) -> some View {
        modifier(GlassPanel(tint: tint, glow: glow, radius: radius, padding: padding))
    }
}
