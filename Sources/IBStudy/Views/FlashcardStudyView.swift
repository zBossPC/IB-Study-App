import SwiftUI

struct FlashcardStudyView: View {
    let sectionId: String
    let cards: [Flashcard]

    @EnvironmentObject private var progress: ProgressStore

    @State private var masteredSet: Set<Int> = []
    @State private var queue: [Int] = []        // indices in review order
    @State private var cursor  = 0
    @State private var flipped = false
    @State private var dragOffset: CGFloat = 0
    @State private var rewardedSession = false
    @State private var gainedXP = 0

    private var currentIdx: Int?   { queue.indices.contains(cursor) ? queue[cursor] : nil }
    private var currentCard: Flashcard? { currentIdx.map { cards[$0] } }
    private var remaining: Int { queue.count }
    private var mastered:  Int { masteredSet.count }

    var body: some View {
        Group {
            if cards.isEmpty {
                ContentUnavailableView("No flashcards", systemImage: "rectangle.on.rectangle.slash")
            } else if queue.isEmpty {
                completedView
            } else {
                studyView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear { resetDeck() }
        .onChange(of: cards.map(\.id).joined()) { _, _ in resetDeck() }
    }

    // MARK: - Completed

    private var completedView: some View {
        VStack(spacing: 22) {
            MascotGuideView(mood: .celebrating, size: MascotSize.flashcardComplete)

            VStack(spacing: 8) {
                Text("Review cleared")
                    .font(.title2.weight(.black))
                    .foregroundStyle(.white)
                Text("All \(cards.count) cards are marked as understood. Nice work locking this stage into memory.")
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)
            }

            if gainedXP > 0 {
                Label("+\(gainedXP) XP earned", systemImage: "star.fill")
                    .font(.headline.weight(.black))
                    .foregroundStyle(GlassTheme.xpColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(GlassTheme.xpColor.opacity(0.12), in: Capsule(style: .continuous))
            }

            Button("Run it again") {
                withAnimation(.spring(response: 0.4)) { resetDeck() }
            }
            .buttonStyle(GamePrimaryButtonStyle(tint: GlassTheme.successColor))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var studyView: some View {
        ScrollView {
            VStack(spacing: 18) {
                progressHeader
                cardArea
                actionFooter
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                MascotGuideView(mood: flipped ? .guiding : .thinking, size: MascotSize.flashcardHeader, showOrb: false)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Review Loop")
                        .font(.title3.weight(.black))
                        .foregroundStyle(.white)
                    Text("Reveal, judge your recall, then keep only the weak cards cycling.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.68))
                }

                Spacer(minLength: 0)

                Button {
                    withAnimation(.spring(response: 0.35)) {
                        queue.shuffle()
                        cursor = 0
                        flipped = false
                    }
                } label: {
                    Label("Shuffle", systemImage: "shuffle")
                        .font(.caption.weight(.bold))
                }
                .buttonStyle(GameSecondaryButtonStyle(tint: GlassTheme.mascotCore))
            }

            HStack(spacing: 12) {
                StatChip(icon: "checkmark.circle.fill", title: "Mastered", value: "\(mastered)", tint: GlassTheme.successColor)
                StatChip(icon: "clock.arrow.circlepath", title: "In Queue", value: "\(remaining)", tint: GlassTheme.mascotCore)
                StatChip(icon: "flame.fill", title: "Streak", value: progress.streakDays > 0 ? "\(progress.streakDays)d" : "Start", tint: GlassTheme.streakColor)
            }

            GameProgressBar(
                progress: Double(mastered) / Double(max(cards.count, 1)),
                tint: GlassTheme.successColor,
                height: 12
            )
        }
        .padding(.horizontal, 26)
        .padding(.top, 24)
        .padding(.bottom, 10)
    }

    private var cardArea: some View {
        Group {
            if let card = currentCard {
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                        .frame(maxWidth: 560, minHeight: 260)
                        .offset(x: 0, y: 10)
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .frame(maxWidth: 560, minHeight: 260)
                        .offset(x: 0, y: 4)

                    cardView(card)
                        .frame(maxWidth: 560)
                }
                    .offset(x: dragOffset)
                    .gesture(swipeGesture)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            flipped.toggle()
                        }
                    }
            }
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func cardView(_ card: Flashcard) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), GlassTheme.mascotCore.opacity(0.06), Color.black.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    flipped ? GlassTheme.mascotCore.opacity(0.40) : Color.white.opacity(0.10),
                    lineWidth: flipped ? 2 : 1
                )

            VStack(spacing: 20) {
                Text(flipped ? "DEFINITION" : "TERM")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(flipped ? GlassTheme.mascotCore : Color.secondary)
                    .tracking(1.8)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(flipped ? GlassTheme.mascotCore.opacity(0.12) : Color.white.opacity(0.06))
                    )

                ZStack {
                    if flipped {
                        Text(card.back)
                            .font(.title3.weight(.medium))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal:   .opacity.combined(with: .scale(scale: 1.02))
                            ))
                            .id("back-\(card.id)")
                    } else {
                        Text(card.front)
                            .font(.title.weight(.black))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal:   .opacity.combined(with: .scale(scale: 1.02))
                            ))
                            .id("front-\(card.id)")
                    }
                }
                .frame(minHeight: 80)
                .padding(.horizontal, 8)

                if !flipped {
                    Text("Tap to reveal · swipe to navigate")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.54))
                }
            }
            .padding(36)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: flipped)
        }
        .frame(minHeight: 260)
        .scaleEffect(flipped ? 0.985 : 1)
        .rotation3DEffect(
            .degrees(flipped ? 7 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.7
        )
        .shadow(color: GlassTheme.mascotCore.opacity(flipped ? 0.16 : 0.06), radius: flipped ? 14 : 8, y: 8)
    }

    private var actionFooter: some View {
        VStack(spacing: 12) {
            if flipped {
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.spring(response: 0.35)) { markCard(mastered: false) }
                    } label: {
                        Label("Still learning", systemImage: "arrow.uturn.backward.circle")
                            .frame(minWidth: 150)
                    }
                    .buttonStyle(GameSecondaryButtonStyle(tint: GlassTheme.mascotGlow))
                    .keyboardShortcut("1", modifiers: [])

                    Button {
                        withAnimation(.spring(response: 0.35)) { markCard(mastered: true) }
                    } label: {
                        Label("Got it!", systemImage: "checkmark.circle.fill")
                            .frame(minWidth: 150)
                    }
                    .buttonStyle(GamePrimaryButtonStyle(tint: GlassTheme.successColor))
                    .keyboardShortcut("2", modifiers: [])
                }
            } else {
                HStack(spacing: 14) {
                    Button {
                        guard cursor > 0 else { return }
                        slideCard(direction: -1) { cursor -= 1; flipped = false }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.bordered)
                    .disabled(cursor == 0)
                    .keyboardShortcut(.leftArrow, modifiers: [])

                    Button("Reveal  ·  Space") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { flipped = true }
                    }
                    .buttonStyle(GameSecondaryButtonStyle(tint: GlassTheme.mascotCore))
                    .keyboardShortcut(.space, modifiers: [])

                    Button {
                        guard cursor < queue.count - 1 else { return }
                        slideCard(direction: 1) { cursor += 1; flipped = false }
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.bordered)
                    .disabled(cursor >= queue.count - 1)
                    .keyboardShortcut(.rightArrow, modifiers: [])
                }
            }

            Text("\(cursor + 1) of \(queue.count) in queue")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.white.opacity(0.50))
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 28)
        .padding(.top, 4)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                dragOffset = value.translation.width * 0.4
            }
            .onEnded { value in
                let threshold: CGFloat = 80
                if value.translation.width < -threshold, cursor < queue.count - 1 {
                    slideCard(direction: 1) { cursor += 1; flipped = false }
                } else if value.translation.width > threshold, cursor > 0 {
                    slideCard(direction: -1) { cursor -= 1; flipped = false }
                } else {
                    withAnimation(.spring(response: 0.3)) { dragOffset = 0 }
                }
            }
    }

    private func resetDeck() {
        masteredSet = []
        queue = Array(0..<cards.count).shuffled()
        cursor = 0
        flipped = false
        dragOffset = 0
        rewardedSession = false
        gainedXP = 0
    }

    private func markCard(mastered gotIt: Bool) {
        guard let idx = currentIdx else { return }
        if gotIt {
            masteredSet.insert(idx)
            queue.remove(at: cursor)
            if cursor >= queue.count, !queue.isEmpty { cursor = max(0, queue.count - 1) }
        } else {
            queue.remove(at: cursor)
            queue.append(idx)
            if cursor >= queue.count { cursor = 0 }
        }
        flipped = false
        rewardIfNeeded()
    }

    private func slideCard(direction: CGFloat, then action: @escaping () -> Void) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) { dragOffset = direction * 50 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            dragOffset = -direction * 50
            action()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) { dragOffset = 0 }
        }
    }

    private func rewardIfNeeded() {
        guard queue.isEmpty, !rewardedSession, !cards.isEmpty else { return }
        rewardedSession = true
        gainedXP = progress.recordFlashcardReview(sectionId: sectionId, total: cards.count)
    }
}
