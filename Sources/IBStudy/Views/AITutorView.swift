import SwiftUI
import AppKit

// MARK: - System prompt

@MainActor
private func buildSystemPrompt() -> String {
    let base = """
    You are IBStudy’s on-device AI coach — the same friendly “mascot” spirit as the app: \
    encouraging, clear, and exam-focused. You tutor IB and AP coursework across economics, \
    physics, and other subjects.

    Guidelines:
    - Be concise but thorough. Use bullet points and numbered steps where helpful.
    - When relevant, reference diagrams and visual aids.
    - Use real-world examples to ground abstract ideas.
    - If a student seems confused, break the concept into smaller steps.
    - Encourage the student and celebrate correct reasoning.
    - Adapt your expertise to whatever subject the student is studying.
    """
    let context = StudyContext.shared.contextBlock
    return base + context
}

private let accent = GlassTheme.mascotGlow

// MARK: - Root view — decides between setup and chat

struct AITutorView: View {
    @EnvironmentObject private var setup    : OllamaSetupManager
    @EnvironmentObject private var progress : ProgressStore

    var body: some View {
        switch setup.phase {
        case .done:
            ChatView(setup: setup)
                .environmentObject(progress)
        case .failed(let msg):
            FailureView(message: msg) { Task { await setup.run() } }
        default:
            SetupProgressView(manager: setup)
        }
    }
}

// MARK: - ─────────────────────────────────────────────────────────────────
// MARK:   Auto-setup progress view
// MARK: ─────────────────────────────────────────────────────────────────

private struct SetupProgressView: View {
    @ObservedObject var manager: OllamaSetupManager

    private let steps: [(SetupStepID, String, String)] = [
        (.install, "Install Ollama",    "ollama install"),
        (.server,  "Start server",      "ollama serve"),
        (.pull,    "Download Gemma 4",  "gemma4:e2b · ~1.5 GB"),
        (.verify,  "Verify model",      "ready to chat"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    tagline
                    stepsColumn
                    if case .pullingModel(let pct, let status) = manager.phase {
                        downloadProgress(pct: pct, status: status)
                    }
                    logBlock
                }
                .padding(28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // ── Header ────────────────────────────────────────────────────────────────

    private var header: some View {
        HStack(spacing: 12) {
            MascotGuideView(mood: .guiding, size: 44, showOrb: false)
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Tutor")
                    .font(.headline.weight(.bold))
                Text("Setting up Gemma 4 · one-time only")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(accent.opacity(0.06))
    }

    // ── Tagline ───────────────────────────────────────────────────────────────

    private var tagline: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Getting Gemma 4 ready")
                    .font(.title2.weight(.bold))
                Text("Runs entirely on your M4 — no internet needed after this, no API key, no cost.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            MascotCalloutCard(
                title: "Your coach is warming up",
                message: "Once the local model finishes loading, the mascot will guide explanations, hints, and challenge breakdowns right inside the app.",
                mood: .thinking
            )
        }
    }

    // ── Step list ─────────────────────────────────────────────────────────────

    private var stepsColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.1.0) { idx, step in
                stepRow(id: step.0, title: step.1, subtitle: step.2, isLast: idx == steps.count - 1)
            }
        }
    }

    private func stepRow(id: SetupStepID, title: String, subtitle: String, isLast: Bool) -> some View {
        let state = stepState(id)
        return HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                stepBadge(state: state)
                if !isLast {
                    Rectangle()
                        .fill(state == .done
                              ? accent.opacity(0.4)
                              : Color.primary.opacity(0.12))
                        .frame(width: 2, height: 36)
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(state == .pending ? .secondary : .primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
            Spacer()
            if state == .active {
                ProgressView()
                    .controlSize(.small)
                    .padding(.top, 4)
            }
        }
        .padding(.bottom, isLast ? 0 : 4)
    }

    // ── Download progress bar ─────────────────────────────────────────────────

    private func downloadProgress(pct: Double, status: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Downloading model")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(pct * 100))%")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(accent)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.08))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(accent.gradient)
                        .frame(width: geo.size.width * pct)
                        .animation(.spring(response: 0.4), value: pct)
                }
            }
            .frame(height: 8)
            Text(status)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(14)
        .background(accent.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(accent.opacity(0.15), lineWidth: 1))
    }

    // ── Log block ─────────────────────────────────────────────────────────────

    @ViewBuilder
    private var logBlock: some View {
        if !manager.log.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("LOG")
                    .font(.system(.caption2, design: .monospaced).weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(manager.log.suffix(20), id: \.self) { line in
                                Text(line)
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .id(line)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                    }
                    .frame(height: 110)
                    .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                    .onChange(of: manager.log.count) { _, _ in
                        if let last = manager.log.last { proxy.scrollTo(last, anchor: .bottom) }
                    }
                }
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    enum SetupStepID { case install, server, pull, verify }
    enum StepState    { case done, active, pending }

    private func stepState(_ id: SetupStepID) -> StepState {
        switch (id, manager.phase) {
        case (.install, .checkingInstall): return .active
        case (.install, .installingOllama): return .active
        case (.install, _): return .done

        case (.server, .startingServer): return .active
        case (.server, .installingOllama): return .pending
        case (.server, .checkingInstall): return .pending
        case (.server, _): return .done

        case (.pull, .pullingModel): return .active
        case (.pull, .done):        return .done
        case (.pull, _):            return .pending

        case (.verify, .done):      return .done
        case (.verify, _):          return .pending
        }
    }

    private func stepBadge(state: StepState) -> some View {
        ZStack {
            Circle()
                .fill(state == .done ? accent : (state == .active ? accent.opacity(0.15) : Color.primary.opacity(0.06)))
                .frame(width: 28, height: 28)
            if state == .done {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
            } else if state == .active {
                Circle().fill(accent).frame(width: 8, height: 8)
            } else {
                Circle().fill(Color.secondary.opacity(0.3)).frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Failure view

private struct FailureView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)
            Text("Setup failed")
                .font(.title2.weight(.bold))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            Button {
                retry()
            } label: {
                Label("Try again", systemImage: "arrow.clockwise")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(accent)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ─────────────────────────────────────────────────────────────────
// MARK:   Chat view
// MARK: ─────────────────────────────────────────────────────────────────

private struct ChatView: View {
    @ObservedObject var setup: OllamaSetupManager
    @ObservedObject private var ollama = OllamaService.shared
    @EnvironmentObject private var progress: ProgressStore

    @State private var history      : [ChatMessage] = []
    @State private var input        = ""
    @State private var isGenerating = false
    @State private var errorMessage : String?
    @State private var serverOnline = true

    var body: some View {
        ZStack {
            PlayfieldBackground()

            VStack(spacing: 0) {
                chatHeader
                Divider()
                if !serverOnline { offlineBanner }
                messageList
                if let err = errorMessage { errorBar(err) }
                Divider()
                inputBar
            }
        }
        .task { await checkServer() }
    }

    // ── Server check ──────────────────────────────────────────────────────────

    private func checkServer() async {
        guard let url = URL(string: "\(OllamaService.baseURL)/api/tags") else { return }
        var req = URLRequest(url: url); req.timeoutInterval = 2
        serverOnline = (try? await URLSession.shared.data(for: req)) != nil
    }

    // ── Header ────────────────────────────────────────────────────────────────

    private var chatHeader: some View {
        HStack(spacing: 12) {
            MascotGuideView(mood: isGenerating ? .thinking : .guiding, size: 48, showOrb: false)
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Tutor")
                    .font(.headline.weight(.bold))
                HStack(spacing: 5) {
                    Circle().fill(serverOnline ? Color.green : Color.orange)
                        .frame(width: 6, height: 6)
                    Text(serverOnline
                         ? "\(OllamaService.recommendedModel) · running locally"
                         : "Ollama offline")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()

            if serverOnline && OllamaService.recommendedModel != "gemma4:e2b" {
                Button {
                    Task { await setup.reinstall(model: "gemma4:e2b") }
                } label: {
                    Label("Switch to Gemma 4 e2b", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accent)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }

            if !history.isEmpty {
                Button {
                    withAnimation { history = []; errorMessage = nil }
                } label: {
                    Label("Clear", systemImage: "trash")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(accent.opacity(0.06))
    }

    // ── Offline banner ────────────────────────────────────────────────────────

    private var offlineBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash").foregroundStyle(.orange)
            Text("Ollama isn't running — open Terminal and run ")
                .font(.caption).foregroundStyle(.secondary)
            Text("ollama serve")
                .font(.system(.caption, design: .monospaced).weight(.semibold))
                .foregroundStyle(.orange)
            Spacer()
            Button("Retry") { Task { await checkServer() } }
                .font(.caption.weight(.semibold))
                .buttonStyle(.plain)
                .foregroundStyle(accent)
        }
        .padding(.horizontal, 18).padding(.vertical, 8)
        .background(Color.orange.opacity(0.08))
    }

    // ── Message list ──────────────────────────────────────────────────────────

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    if history.isEmpty { welcomeState }
                    ForEach(history.filter { $0.role != .system }) { msg in
                        MessageBubble(message: msg).id(msg.id)
                    }
                    if isGenerating && history.last?.role == .user {
                        TypingIndicator().id("typing")
                    }
                }
                .padding(.horizontal, 18).padding(.vertical, 16)
            }
            .onChange(of: history.count) { _, _ in
                withAnimation { if let l = history.last { proxy.scrollTo(l.id, anchor: .bottom) } }
            }
            .onChange(of: isGenerating) { _, v in
                if v { withAnimation { proxy.scrollTo("typing", anchor: .bottom) } }
            }
        }
    }

    // ── Suggestion chips ──────────────────────────────────────────────────────

    private var welcomeState: some View {
        let ctx = StudyContext.shared
        let hasContext = !ctx.currentSectionTitle.isEmpty
        let title = hasContext
            ? "Ask about \(ctx.currentSectionTitle)"
            : "Your study buddy is here"
        let message = hasContext
            ? "I've got context for what you're viewing—ask me to explain, quiz you, or break down anything in \(ctx.currentSubjectTitle)."
            : "Same friendly mascot as the rest of IBStudy. Ask for explanations, comparisons, or quick steps—runs on your Mac with the local model."

        return VStack(alignment: .leading, spacing: 14) {
            MascotCalloutCard(title: title, message: message, mood: .guiding)

            if hasContext {
                HStack(spacing: 6) {
                    Image(systemName: "scope")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(accent)
                    Text("Context: \(ctx.currentSubjectTitle) → \(ctx.currentSectionTitle)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            }

            FlowLayout(spacing: 8) {
                let suggestions = hasContext ? contextualSuggestions(ctx) : defaultSuggestions
                ForEach(suggestions, id: \.self) { s in
                    Button { input = s; sendMessage() } label: {
                        Text(s)
                            .font(.caption.weight(.semibold)).foregroundStyle(accent)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain).contentShape(Rectangle())
                }
            }
        }
    }

    private let defaultSuggestions = [
        "Explain supply and demand.",
        "What is Coulomb's law?",
        "Compare monopoly vs. perfect competition.",
        "What are the methods of charging?",
        "How do electric fields work?",
        "Explain short-run vs. long-run costs.",
    ]

    private func contextualSuggestions(_ ctx: StudyContext) -> [String] {
        [
            "Summarize the key concepts in \(ctx.currentSectionTitle).",
            "What are the most important formulas for this topic?",
            "Give me a practice question on \(ctx.currentSectionTitle).",
            "Explain the hardest part of \(ctx.currentSectionTitle).",
            "How does this connect to other topics?",
        ]
    }

    // ── Error bar ─────────────────────────────────────────────────────────────

    private func errorBar(_ msg: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
            Text(msg).font(.caption).foregroundStyle(.secondary)
            Spacer()
            Button("Dismiss") { errorMessage = nil }.font(.caption).buttonStyle(.plain)
        }
        .padding(.horizontal, 18).padding(.vertical, 8)
        .background(Color.red.opacity(0.07))
    }

    // ── Input bar ─────────────────────────────────────────────────────────────

    private var inputBar: some View {
        HStack(alignment: .center, spacing: 10) {
            NativeChatField(
                placeholder: "Ask about production, costs, monopoly…",
                text: $input,
                onSubmit: sendMessage
            )
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))

            Button { sendMessage() } label: {
                Image(systemName: isGenerating ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
                                     ? Color.secondary.opacity(0.4) : accent)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating)
            .animation(.easeInOut(duration: 0.15), value: isGenerating)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
    }

    // ── Send ──────────────────────────────────────────────────────────────────

    private func sendMessage() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isGenerating else { return }
        input = ""; errorMessage = nil; serverOnline = true

        if history.isEmpty { history.append(ChatMessage(role: .system, content: buildSystemPrompt())) }
        history.append(ChatMessage(role: .user, content: text))
        let placeholder = ChatMessage(role: .assistant, content: "")
        history.append(placeholder)
        let pid = placeholder.id
        isGenerating = true

        ollama.streamChat(
            history: Array(history.dropLast()),
            onToken: { tok in
                if let i = history.firstIndex(where: { $0.id == pid }) { history[i].content += tok }
            },
            onDone: { isGenerating = false },
            onError: { err in
                isGenerating = false
                history.removeAll { $0.id == pid }
                if err.contains("refused") || err.contains("connect") {
                    serverOnline = false
                    errorMessage = "Ollama isn't responding. Run `ollama serve` in Terminal."
                } else {
                    errorMessage = err
                }
            }
        )
    }
}

// MARK: - Message bubble

private struct MessageBubble: View {
    let message: ChatMessage
    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }
            if !isUser {
                MascotGuideView(mood: .guiding, size: 34, showOrb: false)
            }
            Text(message.content.isEmpty ? " " : message.content)
                .font(.body)
                .textSelection(.enabled)
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isUser ? accent : Color.primary.opacity(0.07))
                )
                .foregroundStyle(isUser ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
            if !isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Typing indicator

private struct TypingIndicator: View {
    @State private var phase = 0
    let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 10) {
            MascotGuideView(mood: .thinking, size: 30, showOrb: false)

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(accent.opacity(i == phase ? 0.9 : 0.3))
                        .frame(width: 7, height: 7)
                        .scaleEffect(i == phase ? 1.15 : 0.9)
                        .animation(.easeInOut(duration: 0.25), value: phase)
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
        .onReceive(timer) { _ in phase = (phase + 1) % 3 }
    }
}

// MARK: - Native chat input (NSTextView-based)
// NSTextView has reliable hit-testing and first-responder behaviour on macOS;
// SwiftUI TextField / NSTextField without bezel both lose their click target.

private final class ChatInputTextView: NSTextView {
    var placeholder = "Ask a question…"
    var onSubmit: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard string.isEmpty else { return }
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.placeholderTextColor,
            .font: font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        ]
        let x = textContainerInset.width + (textContainer?.lineFragmentPadding ?? 0)
        let y = textContainerInset.height
        placeholder.draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
    }

    // Enter → submit, Shift+Enter / Option+Enter → newline
    override func insertNewline(_ sender: Any?) {
        let mods = NSApp.currentEvent?.modifierFlags ?? []
        if mods.contains(.shift) || mods.contains(.option) {
            super.insertNewline(sender)
        } else {
            onSubmit?()
        }
    }
}

private struct NativeChatField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var onSubmit: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(owner: self) }

    func makeNSView(context: Context) -> ChatInputTextView {
        let tv = ChatInputTextView()
        tv.placeholder              = placeholder
        tv.onSubmit                 = onSubmit
        tv.delegate                 = context.coordinator
        tv.font                     = .systemFont(ofSize: NSFont.systemFontSize)
        tv.isEditable               = true
        tv.isSelectable             = true
        tv.isRichText               = false
        tv.drawsBackground          = false
        tv.textContainerInset       = .zero
        tv.textContainer?.lineFragmentPadding = 0
        tv.isAutomaticSpellingCorrectionEnabled = false
        tv.isAutomaticQuoteSubstitutionEnabled  = false

        // Retry focus until the view is actually in a window
        func tryFocus(attempts: Int = 8) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if tv.window != nil {
                    tv.window?.makeFirstResponder(tv)
                } else if attempts > 0 {
                    tryFocus(attempts: attempts - 1)
                }
            }
        }
        tryFocus()
        return tv
    }

    func updateNSView(_ tv: ChatInputTextView, context: Context) {
        context.coordinator.owner = self
        tv.placeholder = placeholder
        tv.onSubmit    = onSubmit
        // Clear field after message is sent
        if text.isEmpty, !tv.string.isEmpty {
            tv.string = ""
            tv.needsDisplay = true
            DispatchQueue.main.async { tv.window?.makeFirstResponder(tv) }
        }
    }

    // Tell SwiftUI to use full proposed width and a fixed height
    func sizeThatFits(_ proposal: ProposedViewSize, nsView: ChatInputTextView,
                      context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? 300, height: 28)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var owner: NativeChatField
        init(owner: NativeChatField) { self.owner = owner }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            owner.text = tv.string
        }
    }
}

// MARK: - Flow layout (chip wrapping)

private struct FlowLayout: Layout {
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
