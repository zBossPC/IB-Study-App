import SwiftUI

/// Shared point sizes so the mascot stays legible in sidebars, headers, and chat (avoid one-off tiny values).
enum MascotSize {
    /// Sidebar header badge — sized to `MascotGuideView`’s outer frame (~1.15× width).
    static let sidebarBadge: CGFloat = 112
    static let sectionBannerCompact: CGFloat = 140
    static let sectionBannerWide: CGFloat = 168
    static let welcomeHeroCompact: CGFloat = 128
    static let welcomeHeroWide: CGFloat = 156
    static let panelHeader: CGFloat = 72
    static let chatBubble: CGFloat = 48
    static let typingIndicator: CGFloat = 44
    static let menuBarHeader: CGFloat = 52
    static let menuBarEmpty: CGFloat = 96
    static let menuBarTyping: CGFloat = 40
    /// Assistant avatar next to replies in the menu bar chat
    static let menuBarBubble: CGFloat = 38
    /// Centerpiece while Ollama setup runs in the menu bar panel
    static let menuBarSetup: CGFloat = 80
    static let callout: CGFloat = 136
    static let flashcardComplete: CGFloat = 140
    static let flashcardHeader: CGFloat = 96
    static let quizQuestion: CGFloat = 112
    static let quizResults: CGFloat = 152
    static let splash: CGFloat = 148
}

enum MascotMood {
    case idle
    case guiding
    case thinking
    case celebrating

    var accent: Color {
        switch self {
        case .idle:        return GlassTheme.mascotCore
        case .guiding:     return GlassTheme.mascotGlow
        case .thinking:    return Color.orange
        case .celebrating: return GlassTheme.xpColor
        }
    }

    var symbol: String {
        switch self {
        case .idle:        return "sparkles"
        case .guiding:     return "text.bubble.fill"
        case .thinking:    return "ellipsis.bubble.fill"
        case .celebrating: return "star.fill"
        }
    }

    var title: String {
        switch self {
        case .idle:        return "Ready"
        case .guiding:     return "Guiding"
        case .thinking:    return "Thinking"
        case .celebrating: return "Celebrating"
        }
    }
}

struct MascotGuideView: View {
    var mood: MascotMood = .idle
    var size: CGFloat = 160
    var showOrb = true
    var animated = false

    @State private var drifting = false

    /// Smaller layouts get a slightly stronger halo so the PNG doesn’t disappear on busy backgrounds.
    private var glowOpacity: CGFloat {
        let t = min(size / 180, 1)
        return 0.14 + (1 - t) * 0.10
    }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [mood.accent.opacity(glowOpacity), .clear],
                center: .center,
                startRadius: 4,
                endRadius: size * 0.48
            )
            .frame(width: size * 0.88, height: size * 0.88)

            if showOrb {
                speechOrb
                    .offset(x: size * 0.30, y: -size * 0.20)
            }

            Group {
                if let img = MascotImageLoader.rasterImage() {
                    Image(nsImage: img)
                        .renderingMode(.original)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: size * 0.38, weight: .bold))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .frame(width: size, height: size)
            .shadow(color: mood.accent.opacity(0.28), radius: size * 0.07, y: size * 0.035)
            .rotationEffect(.degrees(animated ? (drifting ? -1.2 : 1.0) : 1.0))
            .offset(y: animated ? (drifting ? -4 : 2) : 2)
            .scaleEffect(animated ? (drifting ? 1.01 : 0.99) : 1)
        }
        .frame(width: size * 1.15, height: size * 1.05)
        .onAppear {
            guard animated else { return }
            withAnimation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true)) {
                drifting = true
            }
        }
    }

    private var speechOrb: some View {
        HStack(spacing: 6) {
            Image(systemName: mood.symbol)
                .font(.caption.weight(.bold))
            Text(mood.title)
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [mood.accent.opacity(0.95), GlassTheme.mascotGlow.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
        )
    }
}

struct MascotCalloutCard: View {
    let title: String
    let message: String
    var mood: MascotMood = .guiding
    var mascotSize: CGFloat = MascotSize.callout

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            MascotGuideView(mood: mood, size: mascotSize, showOrb: false)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.76))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .glassPanel(tint: mood.accent, glow: mood.accent, radius: 24)
    }
}
