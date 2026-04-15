import SwiftUI

struct QuizSessionView: View {
    let sectionId: String
    let questions: [MCQuestion]

    @EnvironmentObject private var progress: ProgressStore

    @State private var step          = 0
    @State private var selected: Int?
    @State private var revealed      = false
    @State private var correctCount  = 0
    @State private var finished      = false
    @State private var lastXP        = 0
    @State private var leveledUp     = false
    @State private var comboStreak   = 0
    @State private var feedbackShake = false
    @State private var showingHint   = false

    private var sectionColor: Color { GlassTheme.sectionColor(sectionId) }
    private var hasDiagram: Bool { ExploreRegistry.hasExplore(sectionId: sectionId) }

    private var currentQ: MCQuestion? {
        guard !finished, questions.indices.contains(step) else { return nil }
        return questions[step]
    }

    var body: some View {
        Group {
            if questions.isEmpty {
                ContentUnavailableView("No questions yet", systemImage: "questionmark.circle")
            } else if finished {
                resultsView
            } else if let q = currentQ {
                questionView(q)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Question view

    private func questionView(_ q: MCQuestion) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                quizHeader

                HStack(alignment: .center, spacing: 18) {
                    MascotGuideView(mood: revealed ? .guiding : .thinking, size: MascotSize.quizQuestion)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Challenge prompt")
                            .font(.caption.weight(.black))
                            .foregroundStyle(.secondary)
                            .tracking(1.4)
                        Text(q.prompt)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        if hasDiagram && !revealed {
                            Button {
                                showingHint = true
                            } label: {
                                Label("Show diagram hint", systemImage: "chart.xyaxis.line")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(sectionColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(sectionColor.opacity(0.10), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }
                    }
                }
                .padding(22)
                .glassPanel(tint: sectionColor, glow: sectionColor, radius: 28)

                VStack(spacing: 10) {
                    ForEach(Array(q.choices.enumerated()), id: \.offset) { idx, text in
                        choiceButton(index: idx, text: text, question: q)
                    }
                }
                .padding(20)
                .glassPanel(tint: sectionColor, glow: .clear, radius: 24)

                if revealed {
                    explanationBlock(q)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))

                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.18)) { advance() }
                        } label: {
                            Label(
                                step < questions.count - 1 ? "Next question" : "See results",
                                systemImage: step < questions.count - 1 ? "arrow.right" : "flag.checkered"
                            )
                            .font(.body.weight(.bold))
                        }
                        .buttonStyle(GamePrimaryButtonStyle(tint: sectionColor))
                        .keyboardShortcut(.return, modifiers: [])
                    }
                }
            }
            .padding(20)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: revealed)
        .sheet(isPresented: $showingHint) {
            HintSheetView(sectionId: sectionId, sectionColor: sectionColor)
        }
    }

    // MARK: - Quiz header

    private var quizHeader: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Challenge Run")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text("Question \(step + 1) of \(questions.count)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.70))
                    if comboStreak >= 2 {
                        Label("\(comboStreak) in a row", systemImage: "bolt.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.orange)
                    }
                }
                Spacer()

                SectionStatusPill(title: "\(correctCount) correct", tint: GlassTheme.successColor)
            }

            GameProgressBar(
                progress: Double(step) / Double(max(questions.count, 1)),
                tint: sectionColor,
                height: 10
            )
        }
        .padding(20)
        .glassPanel(tint: sectionColor, glow: sectionColor, radius: 24)
    }

    // MARK: - Choice button

    @ViewBuilder
    private func choiceButton(index: Int, text: String, question: MCQuestion) -> some View {
        let isSelected = selected == index
        let isCorrect  = index == question.correctIndex
        let isDisabled = revealed

        // Colour state
        let bg: Color = {
            guard revealed else { return .clear }
            if isCorrect            { return .green }
            if isSelected           { return .red }
            return .clear
        }()

        let borderColor: Color = {
            if revealed && isCorrect  { return .green }
            if revealed && isSelected { return .red }
            if isSelected             { return sectionColor }
            return Color.primary.opacity(0.15)
        }()

        let borderWidth: CGFloat = (revealed && (isCorrect || isSelected)) || isSelected ? 2 : 1

        Button {
            guard !revealed else { return }
            withAnimation(.spring(response: 0.28)) {
                selected = index
                revealed = true
                if index == question.correctIndex {
                    correctCount += 1
                    comboStreak  += 1
                } else {
                    comboStreak   = 0
                    feedbackShake.toggle()
                }
            }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                // Letter badge
                ZStack {
                    Circle()
                        .fill(bg.opacity(0.25).blended(withBackground: .thinMaterial))
                    Circle()
                        .strokeBorder(borderColor, lineWidth: 1.5)
                    Text(letter(index))
                        .font(.callout.weight(.bold))
                        .foregroundStyle(
                            revealed
                                ? (isCorrect ? Color.green : (isSelected ? Color.red : .secondary))
                                : (isSelected ? sectionColor : .secondary)
                        )
                }
                .frame(width: 34, height: 34)

                Text(text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(
                        revealed && !isCorrect && !isSelected ? .secondary : .primary
                    )

                // Result icon
                if revealed {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                            .transition(.scale.combined(with: .opacity))
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.title3)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        revealed
                            ? (isCorrect ? Color.green.opacity(0.10) : (isSelected ? Color.red.opacity(0.10) : Color.primary.opacity(0.03)))
                            : (isSelected ? sectionColor.opacity(0.07) : Color.primary.opacity(0.04))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(isSelected ? 1.01 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .shake(feedbackShake && isSelected && !isCorrect)
        .animation(.spring(response: 0.22, dampingFraction: 0.82), value: isSelected)
    }

    // MARK: - Explanation block

    private func explanationBlock(_ q: MCQuestion) -> some View {
        let correct = selected == q.correctIndex
        return VStack(alignment: .leading, spacing: 10) {
            Label(
                correct ? "Correct!" : "Incorrect",
                systemImage: correct ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.callout.weight(.bold))
            .foregroundStyle(correct ? .green : .red)

            if correct && comboStreak >= 3 {
                Label("\(comboStreak) correct in a row — great streak!", systemImage: "bolt.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
            }

            Divider()

            Text(q.explanation)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassPanel(
            tint: correct ? GlassTheme.successColor : .red,
            glow: correct ? GlassTheme.successColor : .red,
            radius: 24
        )
    }

    // MARK: - Results

    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                let pct = Double(correctCount) / Double(max(questions.count, 1))
                let perfect = correctCount == questions.count

                MascotGuideView(mood: perfect ? .celebrating : .guiding, size: MascotSize.quizResults)

                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.10), lineWidth: 10)
                        .frame(width: 142, height: 142)
                    Circle()
                        .trim(from: 0, to: pct)
                        .stroke(
                            perfect ? Color.yellow.gradient : sectionColor.gradient,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 142, height: 142)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8), value: finished)

                    VStack(spacing: 2) {
                        Text("\(correctCount)")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                        Text("/ \(questions.count)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(spacing: 6) {
                    if perfect {
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow.gradient)
                            }
                        }
                        Text("Perfect run!")
                            .font(.title2.weight(.bold))
                        Text("Bonus XP unlocked.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(pct >= 0.7 ? "Good work" : "Keep practising")
                            .font(.title2.weight(.bold))
                        Text("You got \(correctCount) of \(questions.count) correct.")
                            .foregroundStyle(.secondary)
                    }
                }

                MascotCalloutCard(
                    title: perfect ? "Stage mastered" : "Good run",
                    message: perfect
                        ? "That was a clean clear. Enjoy the bonus XP and move forward with momentum."
                        : "You banked progress. Run it again to sharpen weak spots and push this stage to perfect.",
                    mood: perfect ? .celebrating : .guiding
                )

                if leveledUp {
                    Label("Level up!", systemImage: "bolt.circle.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.12), in: Capsule())
                }

                if lastXP > 0 {
                    Text("+\(lastXP) XP")
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundStyle(sectionColor)
                }

                Button {
                    step         = 0
                    selected     = nil
                    revealed     = false
                    correctCount = 0
                    finished     = false
                    lastXP       = 0
                    leveledUp    = false
                    comboStreak  = 0
                } label: {
                    Label("Try again", systemImage: "arrow.counterclockwise")
                        .font(.body.weight(.bold))
                }
                .buttonStyle(GamePrimaryButtonStyle(tint: sectionColor))
            }
            .frame(maxWidth: .infinity)
            .padding(40)
        }
    }

    // MARK: - Helpers

    private func letter(_ index: Int) -> String {
        guard (0..<26).contains(index), let s = UnicodeScalar(UInt32(65 + index)) else { return "?" }
        return String(Character(s))
    }

    private func advance() {
        selected     = nil
        revealed     = false
        if step < questions.count - 1 {
            step += 1
        } else {
            let before = progress.level(for: progress.xp)
            lastXP     = progress.recordQuizCompleted(sectionId: sectionId, correct: correctCount, total: questions.count)
            leveledUp  = progress.level(for: progress.xp) > before
            finished   = true
        }
    }
}

// MARK: - Hint sheet

private struct HintSheetView: View {
    let sectionId: String
    let sectionColor: Color
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("Diagram hint", systemImage: "chart.xyaxis.line")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(sectionColor)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 14)

            Divider()

            ScrollView {
                SectionDiagram(sectionId: sectionId)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .environmentObject(progress)
            }
        }
        .frame(minWidth: 560, minHeight: 480)
    }
}

// MARK: - Shake modifier

private struct ShakeModifier: GeometryEffect {
    var amount: CGFloat = 6
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

private extension View {
    func shake(_ active: Bool) -> some View {
        modifier(ShakeModifier(animatableData: active ? 1 : 0))
            .animation(active ? .easeInOut(duration: 0.4) : .default, value: active)
    }
}

// Tiny helper so we can use Color.blended in the badge fill
private extension Color {
    func blended(withBackground _: Material) -> Color { self }
}
