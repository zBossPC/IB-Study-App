import SwiftUI

struct SectionDetailView: View {
    let section: ContentSection

    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var store: ContentStore

    @State private var studyTab: StudyTab = .learn
    @State private var selectedLesson: Lesson?

    enum StudyTab: String, CaseIterable, Identifiable {
        case learn     = "Learn"
        case review    = "Review"
        case challenge = "Challenge"
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .learn:     return "book.pages.fill"
            case .review:    return "rectangle.on.rectangle.fill"
            case .challenge: return "bolt.circle.fill"
            }
        }

        var subtitle: String {
            switch self {
            case .learn:     return "Short explanations and interactive examples"
            case .review:    return "Repetition mode for memory and speed"
            case .challenge: return "Quiz for XP, streaks, and mastery"
            }
        }
    }

    private var sectionColor: Color { GlassTheme.sectionColor(section.id) }
    private var sectionIconName: String { GlassTheme.sectionIcon(section.id) }
    private var hasDiagram: Bool { ExploreRegistry.hasExplore(sectionId: section.id) }
    private var journeyState: SectionJourneyState { progress.journeyState(for: section, in: [section]) }
    private var completionRatio: Double { progress.completionRatio(for: section) }

    var body: some View {
        ZStack {
            PlayfieldBackground()

            ScrollView {
                VStack(spacing: 18) {
                    sectionBanner
                    tabBar
                    contentArea
                        .frame(maxWidth: .infinity)
                }
                .padding(20)
            }
        }
        .onChange(of: section.id) { _, _ in
            studyTab = .learn
            selectedLesson = section.lessons.first
        }
        .onAppear {
            if selectedLesson == nil { selectedLesson = section.lessons.first }
            updateStudyContext()
        }
        .onChange(of: selectedLesson?.id) { _, _ in
            updateStudyContext()
        }
    }

    private var sectionBanner: some View {
        ViewThatFits(in: .horizontal) {
            bannerRow(compact: false)
            bannerRow(compact: true)
        }
    }

    private var tabBar: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 210, maximum: 420), spacing: 12)], spacing: 12) {
            ForEach(StudyTab.allCases) { tab in
                tabButton(tab)
            }
        }
    }

    private func tabButton(_ tab: StudyTab) -> some View {
        let selected = studyTab == tab
        return Button {
            withAnimation(.spring(response: 0.24, dampingFraction: 0.84)) { studyTab = tab }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill((selected ? sectionColor : .white).opacity(selected ? 0.18 : 0.08))
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(selected ? .white : .secondary)
                    }
                    .frame(width: 34, height: 34)

                    Text(tab.rawValue)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                }

                Text(tab.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.66))
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassPanel(
                tint: selected ? sectionColor : .white,
                glow: selected ? sectionColor : .clear,
                radius: 24
            )
            .animation(.easeOut(duration: 0.16), value: selected)
        }
        .buttonStyle(GameCardButtonStyle())
    }

    @ViewBuilder
    private var contentArea: some View {
        switch studyTab {
        case .learn:
            readLayout
        case .review:
            FlashcardStudyView(sectionId: section.id, cards: section.flashcards)
                .glassPanel(tint: sectionColor, glow: sectionColor, radius: 30)
        case .challenge:
            QuizSessionView(sectionId: section.id, questions: section.questions)
                .glassPanel(tint: sectionColor, glow: sectionColor, radius: 30)
        }
    }

    private var readLayout: some View {
        ViewThatFits(in: .horizontal) {
            wideReadLayout
            compactReadLayout
        }
    }

    private func bannerRow(compact: Bool) -> some View {
        Group {
            if compact {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        SectionBadge(sectionId: section.id, size: 64)
                        bannerText
                    }
                    MascotGuideView(
                        mood: studyTab == .challenge ? .celebrating : (studyTab == .review ? .guiding : .thinking),
                        size: 118,
                        animated: true
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                HStack(alignment: .center, spacing: 18) {
                    SectionBadge(sectionId: section.id, size: 72)
                    bannerText
                    Spacer(minLength: 0)
                    MascotGuideView(
                        mood: studyTab == .challenge ? .celebrating : (studyTab == .review ? .guiding : .thinking),
                        size: 142,
                        animated: true
                    )
                }
            }
        }
        .padding(22)
        .glassPanel(tint: sectionColor, glow: sectionColor, radius: 30)
    }

    private var bannerText: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("STAGE")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.secondary)
                    .tracking(1.2)
                SectionStatusPill(
                    title: journeyState.label,
                    tint: journeyState == .perfect ? GlassTheme.xpColor : sectionColor,
                    emphasized: journeyState == .active || journeyState == .perfect
                )
            }

            Text(section.title)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("\(section.lessons.count) lessons  ·  \(section.flashcards.count) cards  ·  \(section.questions.count) challenge questions")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.72))

            GameProgressBar(progress: completionRatio, tint: sectionColor, height: 10)
                .frame(maxWidth: 360)
        }
    }

    private var wideReadLayout: some View {
        HStack(alignment: .top, spacing: 18) {
            lessonChecklist
                .frame(width: 250)

            lessonContent
        }
    }

    private var compactReadLayout: some View {
        VStack(spacing: 16) {
            lessonChecklist
            lessonContent
        }
    }

    private var lessonChecklist: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Checkpoints")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            VStack(spacing: 10) {
                ForEach(section.lessons) { lesson in
                    lessonRow(lesson)
                        .contentShape(Rectangle())
                        .onTapGesture { selectedLesson = lesson }
                }
            }
        }
        .padding(18)
        .glassPanel(tint: sectionColor, glow: .clear, radius: 28)
    }

    @ViewBuilder
    private var lessonContent: some View {
        if let lesson = selectedLesson {
            VStack(alignment: .leading, spacing: 18) {
                MascotCalloutCard(
                    title: "Lesson checkpoint \(lessonIndex(for: lesson) + 1)",
                    message: "Work through this explanation, then jump to Review or Challenge when it feels natural.",
                    mood: .thinking
                )

                VStack(alignment: .leading, spacing: 18) {
                    Text(lesson.title)
                        .font(.title2.weight(.black))
                        .foregroundStyle(.white)

                    MarkdownLessonView(markdown: lesson.bodyMarkdown)
                        .frame(maxWidth: 760, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(26)
                .glassPanel(tint: sectionColor, glow: .clear, radius: 28)

                if hasDiagram {
                    diagramSection(lessonId: lesson.id)
                }
            }
            .padding(.trailing, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            ContentUnavailableView("Select a lesson", systemImage: "book.pages")
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func diagramSection(lessonId: String) -> some View {
        let secId = diagramSectionId(for: lessonId) ?? section.id
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(sectionColor)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Interactive Lab")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text("Use the controls to see how the model behaves before you jump into the challenge.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.68))
                }
            }

            SectionDiagram(sectionId: secId)
                .padding(6)
        }
        .padding(24)
        .glassPanel(tint: sectionColor, glow: sectionColor, radius: 28)
    }

    private func lessonRow(_ lesson: Lesson) -> some View {
        let isSelected = selectedLesson?.id == lesson.id
        let idx = lessonIndex(for: lesson)
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isSelected ? sectionColor : Color.white.opacity(0.08))
                    .frame(width: 32, height: 32)
                Text("\(idx + 1)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(lesson.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Checkpoint \(idx + 1)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.56))
            }
            Spacer(minLength: 0)
            if isSelected {
                Image(systemName: "play.circle.fill")
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .glassPanel(
            tint: isSelected ? sectionColor : .white,
            glow: isSelected ? sectionColor : .clear,
            radius: 18
        )
        .animation(.easeOut(duration: 0.16), value: isSelected)
    }

    private func lessonIndex(for lesson: Lesson) -> Int {
        section.lessons.firstIndex(where: { $0.id == lesson.id }) ?? 0
    }

    private func updateStudyContext() {
        let subjectTitle = store.selectedSubject?.title ?? ""
        let snippet = selectedLesson?.bodyMarkdown ?? ""
        StudyContext.shared.update(
            subject: subjectTitle,
            section: section.title,
            sectionId: section.id,
            lesson: selectedLesson?.title ?? "",
            snippet: snippet
        )
    }
}
