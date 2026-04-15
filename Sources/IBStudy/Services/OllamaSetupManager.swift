import Foundation

// MARK: - Setup phases

enum SetupPhase: Equatable {
    case checkingInstall
    case installingOllama
    case startingServer
    case pullingModel(progress: Double, statusLine: String)
    case done
    case failed(String)
}

// MARK: - Auto-setup manager

@MainActor
final class OllamaSetupManager: ObservableObject {

    @Published var phase: SetupPhase = .checkingInstall
    @Published var log: [String]     = []

    private var serverProcess: Process?

    // ── Binary paths ──────────────────────────────────────────────────────────

    static var ollamaPath: String? {
        ["/opt/homebrew/bin/ollama", "/usr/local/bin/ollama", "/usr/bin/ollama"]
            .first { FileManager.default.fileExists(atPath: $0) }
    }

    static var brewPath: String? {
        ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
            .first { FileManager.default.fileExists(atPath: $0) }
    }

    // ── Entry point ───────────────────────────────────────────────────────────

    func run() async {
        log.removeAll()
        phase = .checkingInstall

        // 1. Install Ollama if the binary is missing
        if Self.ollamaPath == nil {
            phase = .installingOllama
            addLog("Ollama not found — installing via Homebrew…")
            guard await installOllamaViaBrew() else { return }
        }

        addLog("Ollama binary found at \(Self.ollamaPath ?? "?")")

        // 2. Ensure the HTTP server is running.
        //    If it's already up (menu-bar app, launchd, previous run) we just skip.
        phase = .startingServer
        if await serverIsUp() {
            addLog("Server already running ✓")
        } else {
            addLog("Starting ollama serve…")
            startServerProcess()
            // Poll up to 10 s for the server to respond
            for attempt in 1...20 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if await serverIsUp() { addLog("Server ready ✓"); break }
                if attempt == 20 {
                    phase = .failed("Server did not start after 10 s.\n\nTry running `ollama serve` in Terminal and relaunch the app.")
                    return
                }
            }
        }

        // 3. Pick a model — use whichever candidate is already present, or pull the first that works
        if let present = await firstPresentModel() {
            OllamaService.recommendedModel = present
            addLog("Model \(present) already present ✓")
        } else {
            guard await pullBestAvailableModel() else { return }
        }

        phase = .done
        addLog("Ready!")
    }

    // ── Force-reinstall a specific model ─────────────────────────────────────

    func reinstall(model: String) async {
        log.removeAll()
        // Switch phase immediately so the UI leaves ChatView and shows progress
        phase = .pullingModel(progress: 0, statusLine: "Preparing…")
        addLog("Switching to \(model)…")

        // Ensure server is up first
        let alreadyUp = await serverIsUp()
        if !alreadyUp {
            startServerProcess()
            for attempt in 1...20 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                let up = await serverIsUp()
                if up { break }
                if attempt == 20 {
                    phase = .failed("Server did not start. Run `ollama serve` in Terminal.")
                    return
                }
            }
        }

        let (ok, errText) = await attemptPull(model: model)
        if ok {
            OllamaService.recommendedModel = model
            addLog("Switched to \(model) ✓")
            phase = .done
        } else {
            phase = .failed("Could not pull \(model):\n\n\(errText.isEmpty ? "Unknown error" : errText)")
        }
    }

    // ── Install via Homebrew ──────────────────────────────────────────────────

    private func installOllamaViaBrew() async -> Bool {
        guard let brew = Self.brewPath else {
            phase = .failed(
                "Homebrew is not installed.\n\n" +
                "Install it from https://brew.sh — or download Ollama directly from https://ollama.com — then relaunch the app."
            )
            return false
        }
        addLog("Running: brew install ollama")
        let (ok, output) = await shell(brew, args: ["install", "ollama"])
        if !ok {
            phase = .failed("brew install ollama failed:\n\n\(output)")
            return false
        }
        addLog("Homebrew install complete ✓")
        return true
    }

    // ── Start server ──────────────────────────────────────────────────────────

    private func startServerProcess() {
        guard let path = Self.ollamaPath else { return }
        guard serverProcess?.isRunning != true else { return }

        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments     = ["serve"]
        p.environment   = ProcessInfo.processInfo.environment  // inherit HOME, PATH, etc.
        p.standardOutput = FileHandle.nullDevice
        p.standardError  = FileHandle.nullDevice
        try? p.run()
        serverProcess = p
    }

    // ── Server check ──────────────────────────────────────────────────────────

    private func serverIsUp() async -> Bool {
        guard let url = URL(string: "\(OllamaService.baseURL)/api/tags") else { return false }
        var req = URLRequest(url: url); req.timeoutInterval = 1.5
        return (try? await URLSession.shared.data(for: req)) != nil
    }

    // ── Model selection ───────────────────────────────────────────────────────

    /// Returns the first candidate model that is already downloaded, or nil.
    private func firstPresentModel() async -> String? {
        guard
            let url  = URL(string: "\(OllamaService.baseURL)/api/tags"),
            let (data, _) = try? await URLSession.shared.data(from: url),
            let tags = try? JSONDecoder().decode(_TagsResponse.self, from: data)
        else { return nil }
        let names = tags.models.map(\.name)
        return OllamaService.modelCandidates.first { candidate in
            names.contains(where: { $0.hasPrefix(candidate) })
        }
    }

    /// Tries each model candidate in order; stops at the first successful pull.
    private func pullBestAvailableModel() async -> Bool {
        for candidate in OllamaService.modelCandidates {
            addLog("Trying \(candidate)…")
            let (ok, errText) = await attemptPull(model: candidate)
            if ok {
                OllamaService.recommendedModel = candidate
                addLog("Pulled \(candidate) ✓")
                return true
            }
            // "file does not exist" = model not in registry, try next
            if errText.contains("file does not exist") || errText.contains("not found") {
                addLog("\(candidate) not in registry — trying next…")
                continue
            }
            // Any other error (network, disk, etc.) — surface it and stop
            phase = .failed("Pull failed for \(candidate):\n\n\(errText.isEmpty ? "Unknown error" : errText)")
            return false
        }
        phase = .failed("None of the candidate models could be pulled.\n\nTried: \(OllamaService.modelCandidates.joined(separator: ", "))\n\nCheck your internet connection and try again.")
        return false
    }

    // ── Core pull implementation ──────────────────────────────────────────────

    /// Returns (success, stderr text).
    private func attemptPull(model: String) async -> (Bool, String) {
        guard let path = Self.ollamaPath else { return (false, "Ollama binary not found") }

        return await withCheckedContinuation { continuation in
            var resumed = false
            func finish(_ value: Bool, _ err: String) {
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: (value, err))
            }

            Task.detached { [weak self] in
                guard let self else { finish(false, ""); return }

                let p    = Process()
                let outP = Pipe()
                let errP = Pipe()
                p.executableURL  = URL(fileURLWithPath: path)
                p.arguments      = ["pull", model]
                p.environment    = ProcessInfo.processInfo.environment
                p.standardOutput = outP
                p.standardError  = errP

                outP.fileHandleForReading.readabilityHandler = { handle in
                    let raw = String(data: handle.availableData, encoding: .utf8) ?? ""
                    guard !raw.isEmpty else { return }
                    for line in raw.components(separatedBy: .newlines) {
                        let clean = stripANSI(line).trimmingCharacters(in: .whitespaces)
                        guard !clean.isEmpty else { continue }
                        let pct = parseOllamaProgress(clean)
                        Task { @MainActor [self] in
                            self.addLog(String(clean.prefix(120)))
                            self.phase = .pullingModel(progress: pct ?? self.currentPullProgress,
                                                       statusLine: clean)
                        }
                    }
                }

                let errCollector = LineCollector()
                errP.fileHandleForReading.readabilityHandler = { handle in
                    let raw = String(data: handle.availableData, encoding: .utf8) ?? ""
                    guard !raw.isEmpty else { return }
                    for line in raw.components(separatedBy: .newlines) {
                        let clean = stripANSI(line).trimmingCharacters(in: .whitespaces)
                        guard !clean.isEmpty else { continue }
                        Task { await errCollector.add(clean) }
                    }
                }

                do { try p.run(); p.waitUntilExit() }
                catch { finish(false, error.localizedDescription); return }

                outP.fileHandleForReading.readabilityHandler = nil
                errP.fileHandleForReading.readabilityHandler = nil

                let errText = await errCollector.lines.joined(separator: "\n")
                finish(p.terminationStatus == 0, errText)
            }
        }
    }

    // ── Generic shell helper ──────────────────────────────────────────────────
    // Returns (success, combined stdout+stderr output)

    private func shell(_ exe: String, args: [String]) async -> (Bool, String) {
        await withCheckedContinuation { continuation in
            Task.detached { [self] in
                let p       = Process()
                let pipe    = Pipe()
                let collect = LineCollector()
                p.executableURL  = URL(fileURLWithPath: exe)
                p.arguments      = args
                p.environment    = ProcessInfo.processInfo.environment
                p.standardOutput = pipe
                p.standardError  = pipe

                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let s = String(data: handle.availableData, encoding: .utf8) ?? ""
                    guard !s.isEmpty else { return }
                    for line in s.components(separatedBy: .newlines) {
                        let t = stripANSI(line).trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { continue }
                        Task { await collect.add(t) }
                        Task { @MainActor [self] in self.addLog(String(t.prefix(120))) }
                    }
                }

                do { try p.run(); p.waitUntilExit() }
                catch { continuation.resume(returning: (false, error.localizedDescription)); return }

                pipe.fileHandleForReading.readabilityHandler = nil
                let output = await collect.lines.joined(separator: "\n")
                continuation.resume(returning: (p.terminationStatus == 0, output))
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private var currentPullProgress: Double {
        if case .pullingModel(let p, _) = phase { return p } else { return 0 }
    }

    private func addLog(_ msg: String) {
        log.append(msg)
        if log.count > 100 { log.removeFirst() }
    }
}

// MARK: - Free helpers

private func parseOllamaProgress(_ line: String) -> Double? {
    guard let range = line.range(of: #"(\d{1,3})%"#, options: .regularExpression),
          let pct   = Double(line[range].dropLast()) else { return nil }
    return pct / 100.0
}

private func stripANSI(_ s: String) -> String {
    s.replacingOccurrences(of: #"\u{1B}\[[0-9;]*[mGKHF]"#, with: "", options: .regularExpression)
     .replacingOccurrences(of: #"\u{1B}\[[\d;]*[A-Za-z]"#, with: "", options: .regularExpression)
}

// Thread-safe line accumulator used inside Task.detached
private actor LineCollector {
    var lines: [String] = []
    func add(_ line: String) { lines.append(line) }
}

private struct _TagsResponse: Decodable {
    struct M: Decodable { let name: String }
    let models: [M]
}
