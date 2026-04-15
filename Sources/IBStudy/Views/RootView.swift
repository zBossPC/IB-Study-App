import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store    : ContentStore
    @EnvironmentObject private var progress : ProgressStore
    @EnvironmentObject private var aiSetup  : OllamaSetupManager
    @Environment(\.checkForUpdates) private var checkForUpdates

    @Environment(\.openWindow) private var openWindow

    @AppStorage("ibstudy.welcomeSplashCompleted") private var welcomeSplashCompleted = false
    @State private var showWelcomeSplash = false

    @State private var sidebarSelection : SidebarSelection = .home
    @State private var showAchievements = false

    var body: some View {
        Group {
            if let error = store.loadError, store.subjects.isEmpty {
                ContentUnavailableView {
                    Label("Could not load content", systemImage: "exclamationmark.triangle")
                } description: { Text(error) }

            } else if let subject = store.selectedSubject {
                NavigationSplitView(columnVisibility: .constant(.all)) {
                    sidebarContent(subject: subject)
                        .navigationSplitViewColumnWidth(min: 232, ideal: 268, max: 320)
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            SidebarFooterPanel(showAchievements: $showAchievements)
                                .environmentObject(progress)
                        }
                } detail: {
                    detailView(subject: subject)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: 8) {
                            Button {
                                checkForUpdates()
                            } label: {
                                Label("Update", systemImage: "arrow.down.circle")
                            }
                            .help("Check for updates…")

                            Button {
                                openWindow(id: "ai-tutor")
                            } label: {
                                Label("Ask AI", systemImage: "sparkles")
                            }
                            .buttonStyle(.borderedProminent)
                            .help("Ask AI Tutor  ⌘/")
                            .keyboardShortcut("/", modifiers: .command)
                        }
                    }
                }
                .onAppear {
                    if !welcomeSplashCompleted {
                        showWelcomeSplash = true
                    }
                }
                .overlay {
                    if showWelcomeSplash {
                        FirstLaunchSplashView(
                            isPresented: Binding(
                                get: { showWelcomeSplash },
                                set: { newValue in
                                    showWelcomeSplash = newValue
                                    if !newValue { welcomeSplashCompleted = true }
                                }
                            ),
                            accent: subject.color
                        )
                        .zIndex(1000)
                    }
                }
                .sheet(isPresented: $showAchievements) {
                    NavigationStack {
                        AchievementsView()
                            .environmentObject(progress)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Done") { showAchievements = false }
                                }
                            }
                    }
                    .environmentObject(progress)
                    .frame(minWidth: 440, minHeight: 500)
                }

            } else {
                ProgressView("Loading…").frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 960, minHeight: 660)
    }

    // MARK: - Sidebar

    @ViewBuilder
    private func sidebarContent(subject: Subject) -> some View {
        ZStack {
            PlayfieldBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    sidebarHeader(subject: subject)

                    if store.subjects.count > 1 {
                        subjectPicker
                    }

                    homeLaunchCard(subject: subject)
                    pathRail(subject: subject)
                    toolsCard
                }
            }
            .padding(16)
        }
    }

    private func sidebarHeader(subject: Subject) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [subject.color.opacity(0.95), GlassTheme.mascotGlow.opacity(0.78)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 3) {
                Text("IBStudy")
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                Text(subject.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
            }
            Spacer()
        }
        .padding(16)
        .glassPanel(tint: subject.color, glow: subject.color, radius: 24)
    }

    private var subjectPicker: some View {
        HStack(spacing: 6) {
            ForEach(store.subjects) { subj in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        store.selectedSubjectId = subj.id
                        sidebarSelection = .home
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: subj.icon)
                            .font(.system(size: 11, weight: .semibold))
                        Text(subj.title)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(
                        store.selectedSubjectId == subj.id
                            ? subj.color.opacity(0.20)
                            : Color.white.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(
                                store.selectedSubjectId == subj.id
                                    ? subj.color.opacity(0.45)
                                    : Color.clear,
                                lineWidth: 1
                            )
                    )
                    .foregroundStyle(
                        store.selectedSubjectId == subj.id ? .white : .secondary
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .glassPanel(tint: .white, glow: .clear, radius: 16)
    }

    private func homeLaunchCard(subject: Subject) -> some View {
        Button {
            withAnimation(.spring(response: 0.28)) {
                sidebarSelection = .home
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(subject.color.opacity(0.16))
                    Image(systemName: "house.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Mission Home")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text("View your campaign, stats, and next stage")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.68))
                }

                Spacer(minLength: 0)
                Image(systemName: sidebarSelection == .home ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    .foregroundStyle(.white)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(GameCardButtonStyle())
        .glassPanel(
            tint: sidebarSelection == .home ? subject.color : .white,
            glow: sidebarSelection == .home ? subject.color : .clear,
            radius: 22
        )
    }

    private func pathRail(subject: Subject) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Path Rail")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(progress.completedSectionCount(in: subject.payload.sections))/\(subject.payload.sections.count)")
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white.opacity(0.74))
            }

            VStack(spacing: 10) {
                ForEach(Array(subject.payload.sections.enumerated()), id: \.element.id) { idx, section in
                    VStack(spacing: 8) {
                        sidebarSectionRow(section, sections: subject.payload.sections, index: idx + 1)
                        if idx < subject.payload.sections.count - 1 {
                            RoundedRectangle(cornerRadius: 999, style: .continuous)
                                .fill(subject.color.opacity(0.22))
                                .frame(width: 3, height: 16)
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassPanel(tint: subject.color, glow: subject.color, radius: 26)
    }

    private func sidebarSectionRow(_ section: ContentSection, sections: [ContentSection], index: Int) -> some View {
        let color = GlassTheme.sectionColor(section.id)
        let state = progress.journeyState(for: section, in: sections)
        let best = progress.quizBestBySection[section.id]
        let isSelected = sidebarSelection == .section(section.id)

        return Button {
            withAnimation(.spring(response: 0.28)) {
                sidebarSelection = .section(section.id)
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.18))
                        .frame(width: 30, height: 30)
                    Text("\(index)")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white)
                }

                SectionBadge(sectionId: section.id, size: 38)

                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    SectionStatusPill(
                        title: state.label,
                        tint: state == .perfect ? GlassTheme.xpColor : color,
                        emphasized: state == .active || state == .perfect
                    )

                    if let best {
                        Text("\(best)/\(section.questions.count) challenge score")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.white.opacity(0.64))
                    } else {
                        Text("\(section.lessons.count) lessons ready")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.56))
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "play.circle.fill" : "chevron.right")
                    .font(.callout.weight(.bold))
                    .foregroundStyle(.white.opacity(0.78))
            }
            .padding(14)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(GameCardButtonStyle())
        .glassPanel(
            tint: isSelected ? color : color.opacity(0.55),
            glow: isSelected ? color : .clear,
            radius: 20
        )
        .opacity(state == .locked ? 0.76 : 1)
    }

    private var toolsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Support Tools")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            sidebarToolButton(symbol: "sparkles", color: GlassTheme.mascotCore, label: "AI Tutor", subtitle: "Ask for hints and explanations") {
                sidebarSelection = .aiTutor
            }

            sidebarToolButton(symbol: "text.magnifyingglass", color: .gray, label: "Glossary", subtitle: "Fast concept lookups") {
                sidebarSelection = .glossary
            }

            sidebarToolButton(symbol: "arrow.down.circle", color: Color.cyan.opacity(0.9), label: "Check for Updates", subtitle: "Get the latest build") {
                checkForUpdates()
            }
        }
        .padding(16)
        .glassPanel(tint: GlassTheme.mascotCore, glow: .clear, radius: 24)
    }

    private func sidebarToolButton(
        symbol: String,
        color: Color,
        label: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.16))
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(color)
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.60))
                }

                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(14)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(GameCardButtonStyle())
        .glassPanel(tint: color, glow: .clear, radius: 18)
    }

    // MARK: - Detail

    @ViewBuilder
    private func detailView(subject: Subject) -> some View {
        let payload = subject.payload
        switch sidebarSelection {
        case .home:
            WelcomeDashboardView(subject: subject, selection: $sidebarSelection)
                .environmentObject(progress)

        case .aiTutor:
            AITutorView()
                .environmentObject(aiSetup)
                .environmentObject(progress)

        case .glossary:
            NavigationStack {
                GlossaryView(terms: payload.glossary)
                    .navigationTitle("Glossary")
            }

        case .section(let id):
            if let section = payload.sections.first(where: { $0.id == id }) {
                NavigationStack {
                    SectionDetailView(section: section)
                }
            } else {
                ContentUnavailableView("Select a topic", systemImage: "sidebar.left")
            }
        }
    }
}
