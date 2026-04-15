import SwiftUI

struct WelcomeDashboardView: View {
    let subject: Subject
    @Binding var selection: SidebarSelection
    @EnvironmentObject private var progress: ProgressStore

    private var payload: UnitPayload { subject.payload }
    private let columns = [GridItem(.adaptive(minimum: 220, maximum: 340), spacing: 16)]
    private var recommendedSection: ContentSection? { progress.recommendedSection(in: payload.sections) }
    private var totalLessons: Int { payload.sections.reduce(0) { $0 + $1.lessons.count } }
    private var totalCards: Int { payload.sections.reduce(0) { $0 + $1.flashcards.count } }
    private var totalQuestions: Int { payload.sections.reduce(0) { $0 + $1.questions.count } }
    private var sectionsCleared: Int { progress.completedSectionCount(in: payload.sections) }

    var body: some View {
        ZStack {
            PlayfieldBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    heroHeader
                    progressRow
                    pathOverview
                    toolsRow
                }
                .padding(28)
            }
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            ViewThatFits(in: .horizontal) {
                heroTopRow(compact: false)
                heroTopRow(compact: true)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Mission brief")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text(recommendedSection.map {
                    "You're closest to clearing \($0.title). Keep your streak alive, finish the lesson path, then lock in the win with a challenge run."
                } ?? "Everything in this path is cleared. Revisit a stage, perfect your quiz scores, or open the tutor for a harder explanation.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 12) {
                Button {
                    if let section = recommendedSection {
                        selection = .section(section.id)
                    }
                } label: {
                    Label("Continue Path", systemImage: "arrow.right.circle.fill")
                        .font(.headline.weight(.bold))
                }
                .buttonStyle(GamePrimaryButtonStyle(tint: subject.color))

                Button {
                    selection = .aiTutor
                } label: {
                    Label("Ask The Coach", systemImage: "sparkles")
                        .font(.headline.weight(.bold))
                }
                .buttonStyle(GameSecondaryButtonStyle(tint: GlassTheme.mascotCore))
            }
        }
        .padding(26)
        .glassPanel(tint: subject.color, glow: subject.color, radius: GlassTheme.heroRadius)
    }

    @ViewBuilder
    private func heroTopRow(compact: Bool) -> some View {
        if compact {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    subjectBadge(size: 84)
                    VStack(alignment: .leading, spacing: 8) {
                        heroTextBlock(titleSize: 34)
                    }
                }
                MascotGuideView(mood: .guiding, size: 108, animated: true)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        } else {
            HStack(alignment: .top, spacing: 18) {
                subjectBadge(size: 96)
                VStack(alignment: .leading, spacing: 10) {
                    heroTextBlock(titleSize: 42)
                }
                Spacer(minLength: 0)
                MascotGuideView(mood: .guiding, size: 132, animated: true)
            }
        }
    }

    private func subjectBadge(size: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            subject.color.opacity(0.92),
                            subject.color.opacity(0.52),
                            GlassTheme.mascotGlow.opacity(0.46)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            Image(systemName: subject.icon)
                .font(.system(size: size * 0.43, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }

    private func heroTextBlock(titleSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CURRENT CAMPAIGN")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1.6)

            Text(subject.title)
                .font(.system(size: titleSize, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(subject.subtitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))

            Text("\(payload.sections.count) stages  ·  \(totalLessons) lessons  ·  \(totalCards) flashcards  ·  \(totalQuestions) quiz prompts")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.70))
        }
    }

    private var progressRow: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            StatChip(icon: "bolt.fill", title: "Current Level", value: "Lv \(progress.level(for: progress.xp))", tint: GlassTheme.xpColor)
            StatChip(icon: "star.fill", title: "Lifetime XP", value: "\(progress.xp)", tint: GlassTheme.xpColor)
            StatChip(icon: "flame.fill", title: "Streak", value: progress.streakDays > 0 ? "\(progress.streakDays) days" : "Start today", tint: GlassTheme.streakColor)
            StatChip(icon: "checkmark.seal.fill", title: "Stages Cleared", value: "\(sectionsCleared)/\(payload.sections.count)", tint: subject.color)
        }
    }

    private var pathOverview: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Learning Path")
                        .font(.title2.weight(.black))
                        .foregroundStyle(.white)
                    Text("Clear stages in order, revisit them for perfect scores, and keep momentum with short wins.")
                        .foregroundStyle(.white.opacity(0.74))
                }
                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("Path Progress")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text("\(Int((Double(sectionsCleared) / Double(max(payload.sections.count, 1))) * 100))%")
                        .font(.title3.weight(.black))
                        .foregroundStyle(.white)
                }
            }

            GameProgressBar(
                progress: Double(sectionsCleared) / Double(max(payload.sections.count, 1)),
                tint: subject.color,
                height: 12
            )

            VStack(spacing: 12) {
                ForEach(Array(payload.sections.enumerated()), id: \.element.id) { idx, section in
                    VStack(spacing: 10) {
                        PathStageCard(
                            section: section,
                            index: idx + 1,
                            state: progress.journeyState(for: section, in: payload.sections),
                            progressRatio: progress.completionRatio(for: section),
                            selection: $selection
                        )
                        if idx < payload.sections.count - 1 {
                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                .fill(subject.color.opacity(0.20))
                                .frame(width: 4, height: 22)
                        }
                    }
                }
            }
        }
        .padding(24)
        .glassPanel(tint: subject.color, glow: subject.color, radius: 28)
    }

    private var toolsRow: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            dashboardToolCard(
                title: "Glossary Run",
                subtitle: "\(payload.glossary.count) quick definitions ready to search",
                icon: "text.magnifyingglass",
                tint: .gray
            ) {
                selection = .glossary
            }

            dashboardToolCard(
                title: "AI Coach",
                subtitle: "Get hints, summaries, and confidence boosts",
                icon: "sparkles",
                tint: GlassTheme.mascotCore
            ) {
                selection = .aiTutor
            }
        }
    }

    private func dashboardToolCard(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.18))
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(tint)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.70))
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.right")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.80))
            }
            .padding(18)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .buttonStyle(GameCardButtonStyle())
        .glassPanel(tint: tint, glow: tint)
    }
}

private struct PathStageCard: View {
    let section: ContentSection
    let index: Int
    let state: SectionJourneyState
    let progressRatio: Double
    @Binding var selection: SidebarSelection

    private var sectionColor: Color { GlassTheme.sectionColor(section.id) }
    private var statusTint: Color {
        switch state {
        case .locked:   return .secondary
        case .active:   return sectionColor
        case .explored: return GlassTheme.mascotCore
        case .mastered: return GlassTheme.successColor
        case .perfect:  return GlassTheme.xpColor
        }
    }

    var body: some View {
        Button { selection = .section(section.id) } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(statusTint.opacity(0.16))
                        .frame(width: 36, height: 36)
                    Text("\(index)")
                        .font(.callout.weight(.black))
                        .foregroundStyle(state == .locked ? Color.secondary : .white)
                }

                SectionBadge(sectionId: section.id, size: 54)

                VStack(alignment: .leading, spacing: 8) {
                    Text(section.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    SectionStatusPill(
                        title: state.label,
                        tint: statusTint,
                        emphasized: state == .active || state == .perfect
                    )

                    Text("\(section.lessons.count) lessons  ·  \(section.flashcards.count) cards  ·  \(section.questions.count) challenge questions")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.68))

                    GameProgressBar(progress: progressRatio, tint: statusTint, height: 9, showGlow: state != .locked)
                }

                Spacer(minLength: 0)

                Image(systemName: state == .locked ? "lock.fill" : "play.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(state == .locked ? Color.secondary : .white)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .glassPanel(
                tint: state == .locked ? .white : statusTint,
                glow: state == .active ? statusTint : .clear,
                radius: 24
            )
            .opacity(state == .locked ? 0.72 : 1)
        }
        .buttonStyle(.plain)
        .buttonStyle(GameCardButtonStyle())
    }
}
