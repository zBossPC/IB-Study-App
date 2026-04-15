import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    private let appVersion: String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }()
    private let buildNumber: String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                heroCard
                infoGrid
                creditsSection
                techStack
                legalSection
            }
            .padding(28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.pageGradient.ignoresSafeArea())
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [themeManager.current.accentCore.opacity(0.3), .clear],
                            center: .center, startRadius: 20, endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(themeManager.current.accentCore)
            }

            Text("IBStudy")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(.white)

            Text("Version \(appVersion) (Build \(buildNumber))")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.white.opacity(0.6))

            Text("A native macOS study companion for IB and AP coursework.\nBuilt with SwiftUI for focus, practice, and local AI.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 460)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .glassPanel(tint: themeManager.current.accentCore, glow: themeManager.current.accentCore, radius: 28)
    }

    // MARK: - Info grid

    private var infoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            aboutStat(icon: "desktopcomputer", label: "Platform", value: "macOS Tahoe (26+)")
            aboutStat(icon: "swift", label: "Built with", value: "SwiftUI & SPM")
            aboutStat(icon: "cpu", label: "AI Engine", value: "Ollama (Gemma 4)")
            aboutStat(icon: "lock.shield.fill", label: "Privacy", value: "100% local")
            aboutStat(icon: "arrow.down.circle.fill", label: "Updates", value: "Sparkle 2")
            aboutStat(icon: "doc.text.fill", label: "License", value: "MIT")
        }
    }

    private func aboutStat(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(themeManager.current.accentCore.opacity(0.14))
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(themeManager.current.accentCore)
            }
            .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(14)
        .glassPanel(tint: themeManager.current.accentCore, glow: .clear, radius: 16)
    }

    // MARK: - Credits

    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Credits", systemImage: "person.2.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 10) {
                creditRow(name: "zBossPC", role: "Creator & Developer")
                creditRow(name: "Ollama", role: "Local AI inference engine")
                creditRow(name: "Sparkle", role: "macOS update framework")
                creditRow(name: "Google", role: "Gemma 4 language model")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(tint: .white, glow: .clear, radius: 22)
    }

    private func creditRow(name: String, role: String) -> some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            Spacer()
            Text(role)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Tech stack

    private var techStack: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Tech Stack", systemImage: "hammer.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            FlowBadges(items: [
                "SwiftUI", "Swift 6.2", "SPM", "macOS 26",
                "Ollama", "Gemma 4", "Sparkle 2",
                "Canvas (Diagrams)", "Markdown Renderer",
                "UserDefaults", "NSTextView", "MenuBarExtra"
            ], tint: themeManager.current.accentCore)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(tint: .white, glow: .clear, radius: 22)
    }

    // MARK: - Legal

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Disclaimer")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.5))
            Text("IBStudy is an independent project and is not affiliated with or endorsed by the International Baccalaureate Organization or the College Board. IB is a registered trademark of the International Baccalaureate Organization. AP is a registered trademark of the College Board.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
                .lineSpacing(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(tint: .white, glow: .clear, radius: 18)
    }
}

struct FlowBadges: View {
    let items: [String]
    let tint: Color

    var body: some View {
        FlowBadgeLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(tint.opacity(0.10), in: Capsule(style: .continuous))
                    .overlay(Capsule(style: .continuous).strokeBorder(tint.opacity(0.25), lineWidth: 1))
            }
        }
    }
}

private struct FlowBadgeLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let w = proposal.width ?? 400
        var x: CGFloat = 0, y: CGFloat = 0, rh: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > w, x > 0 { y += rh + spacing; x = 0; rh = 0 }
            rh = max(rh, s.height); x += s.width + spacing
        }
        return CGSize(width: w, height: y + rh)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rh: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX, x > bounds.minX { y += rh + spacing; x = bounds.minX; rh = 0 }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            rh = max(rh, s.height); x += s.width + spacing
        }
    }
}
