import SwiftUI

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

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [mood.accent.opacity(0.14), .clear],
                center: .center,
                startRadius: 4,
                endRadius: size * 0.42
            )
            .frame(width: size * 0.82, height: size * 0.82)

            if showOrb {
                speechOrb
                    .offset(x: size * 0.30, y: -size * 0.20)
            }

            Image("MascotGuide", bundle: .module)
                .renderingMode(.original)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: size, height: size)
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

    var body: some View {
        HStack(spacing: 16) {
            MascotGuideView(mood: mood, size: 88, showOrb: false)

            VStack(alignment: .leading, spacing: 6) {
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
        .padding(18)
        .glassPanel(tint: mood.accent, glow: mood.accent, radius: 24)
    }
}
