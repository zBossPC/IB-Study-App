import SwiftUI
import AppKit

// MARK: - Menu bar popup
// Shown when the user clicks the ✦ sparkles icon in the system menu bar.
// Compact (380 × 560) version of the AI chat; shares the same OllamaSetupManager
// so setup state is already done by the time they open this.

struct MenuBarAIView: View {
    @EnvironmentObject private var setup    : OllamaSetupManager
    @EnvironmentObject private var progress : ProgressStore

    var body: some View {
        VStack(spacing: 0) {
            handle
            Divider()
            content
        }
        .frame(width: 380, height: 560)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.10), GlassTheme.mascotGlow.opacity(0.06), Color.black.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // ── Drag handle / header ──────────────────────────────────────────────────

    private var handle: some View {
        HStack(spacing: 10) {
            MascotGuideView(mood: setup.phase == .done ? .guiding : .thinking, size: 34, showOrb: false)
            Text("AI Tutor")
                .font(.headline.weight(.semibold))
            Spacer()
            // Status dot
            HStack(spacing: 5) {
                Circle()
                    .fill(setup.phase == .done ? Color.green : Color.orange)
                    .frame(width: 6, height: 6)
                Text(setup.phase == .done ? "Ready" : "Setting up…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // ── Main content ──────────────────────────────────────────────────────────

    @ViewBuilder
    private var content: some View {
        switch setup.phase {
        case .done:
            MenuBarChatView()
                .environmentObject(progress)
        case .failed(let msg):
            MenuBarErrorView(message: msg) { Task { await setup.run() } }
        default:
            MenuBarSetupView(manager: setup)
        }
    }
}

// MARK: - Chat (compact)

private struct MenuBarChatView: View {
    @EnvironmentObject private var progress: ProgressStore
    @ObservedObject private var ollama = OllamaService.shared

    @State private var history      : [ChatMessage] = []
    @State private var input        = ""
    @State private var isGenerating = false
    @State private var errorMessage : String?

    private let accent = GlassTheme.mascotGlow

    var body: some View {
        VStack(spacing: 0) {
            messages
            if let err = errorMessage { errorBanner(err) }
            Divider()
            inputRow
        }
    }

    // ── Messages ──────────────────────────────────────────────────────────────

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    if history.isEmpty { emptyState }
                    ForEach(history.filter { $0.role != .system }) { msg in
                        compactBubble(msg).id(msg.id)
                    }
                    if isGenerating && history.last?.role == .user {
                        compactTyping.id("typing")
                    }
                }
                .padding(12)
            }
            .onChange(of: history.count) { _, _ in
                withAnimation { if let l = history.last { proxy.scrollTo(l.id, anchor: .bottom) } }
            }
            .onChange(of: isGenerating) { _, v in
                if v { withAnimation { proxy.scrollTo("typing", anchor: .bottom) } }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            MascotGuideView(mood: .guiding, size: 76, showOrb: false)
            Text("Ask anything about AP Micro")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Your study companion is online.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func compactBubble(_ msg: ChatMessage) -> some View {
        let isUser = msg.role == .user
        return HStack(alignment: .bottom, spacing: 6) {
            if isUser { Spacer(minLength: 40) }
            Text(msg.content.isEmpty ? " " : msg.content)
                .font(.subheadline)
                .textSelection(.enabled)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isUser ? accent : Color.primary.opacity(0.08))
                )
                .foregroundStyle(isUser ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
            if !isUser { Spacer(minLength: 40) }
        }
    }

    private var compactTyping: some View {
        HStack(spacing: 8) {
            MascotGuideView(mood: .thinking, size: 22, showOrb: false)
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(accent.opacity(0.5)).frame(width: 6, height: 6)
                }
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    // ── Error ─────────────────────────────────────────────────────────────────

    private func errorBanner(_ msg: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red).font(.caption)
            Text(msg).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            Spacer()
            Button("✕") { errorMessage = nil }.font(.caption).buttonStyle(.plain)
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(Color.red.opacity(0.08))
    }

    // ── Input ─────────────────────────────────────────────────────────────────

    private var inputRow: some View {
        HStack(spacing: 8) {
            NativeMenuBarField(placeholder: "Ask a question…", text: $input, onSubmit: send)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))

            Button { send() } label: {
                Image(systemName: isGenerating ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(
                        input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
                            ? Color.secondary.opacity(0.4) : accent
                    )
            }
            .buttonStyle(.plain)
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating)
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
    }

    // ── Send ──────────────────────────────────────────────────────────────────

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isGenerating else { return }
        input = ""; errorMessage = nil
        if history.isEmpty {
            history.append(ChatMessage(role: .system, content: menuBarSystemPrompt))
        }
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
                errorMessage = err
            }
        )
    }
}

// MARK: - Setup progress (compact)

private struct MenuBarSetupView: View {
    @ObservedObject var manager: OllamaSetupManager
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(phaseLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if case .pullingModel(let pct, _) = manager.phase {
                ProgressView(value: pct)
                    .tint(.indigo)
                    .padding(.horizontal, 32)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    private var phaseLabel: String {
        switch manager.phase {
        case .checkingInstall:  return "Checking Ollama…"
        case .installingOllama: return "Installing Ollama…"
        case .startingServer:   return "Starting server…"
        case .pullingModel:     return "Downloading model…"
        default:                return "Setting up…"
        }
    }
}

// MARK: - Error (compact)

private struct MenuBarErrorView: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32)).foregroundStyle(.orange)
            Text(message)
                .font(.caption).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            Button("Try again", action: retry)
                .buttonStyle(.borderedProminent).tint(.indigo)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Dedicated NSTextField wrapper for the menu bar popup

private final class MenuBarTextField: NSTextField {
    override var acceptsFirstResponder: Bool { true }
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        super.mouseDown(with: event)
    }
}

private struct NativeMenuBarField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var onSubmit: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(owner: self) }

    func makeNSView(context: Context) -> MenuBarTextField {
        let f = MenuBarTextField()
        f.placeholderString  = placeholder
        f.isBordered         = false
        f.isBezeled          = false
        f.drawsBackground    = false
        f.focusRingType      = .none
        f.font               = .systemFont(ofSize: NSFont.systemFontSize - 1)
        f.isEditable         = true
        f.delegate           = context.coordinator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            f.window?.makeFirstResponder(f)
        }
        return f
    }

    func updateNSView(_ f: MenuBarTextField, context: Context) {
        context.coordinator.owner = self
        if text.isEmpty, !f.stringValue.isEmpty { f.stringValue = "" }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: MenuBarTextField,
                      context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? 260, height: 22)
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var owner: NativeMenuBarField
        init(owner: NativeMenuBarField) { self.owner = owner }
        func controlTextDidChange(_ n: Notification) {
            owner.text = (n.object as? NSTextField)?.stringValue ?? owner.text
        }
        func control(_ control: NSControl, textView: NSTextView,
                     doCommandBy cmd: Selector) -> Bool {
            if cmd == #selector(NSResponder.insertNewline(_:)) {
                owner.onSubmit(); return true
            }
            return false
        }
    }
}

// MARK: - System prompt (concise for the compact popup)

private let menuBarSystemPrompt = """
You are a concise AP Microeconomics tutor. Answer questions about Unit 3 \
(production, costs, perfect competition, monopoly, monopolistic competition). \
Keep answers short and clear — 2-4 sentences unless the student asks for more detail.
"""
