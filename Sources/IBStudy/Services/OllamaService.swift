import Foundation

// MARK: - Model

struct ChatMessage: Identifiable, Equatable {
    enum Role: String { case system, user, assistant }
    let id    = UUID()
    let role  : Role
    var content: String
}

// MARK: - Ollama wire types

private struct OllamaRequest: Encodable {
    struct Msg: Encodable { let role: String; let content: String }
    let model    : String
    let messages : [Msg]
    let stream   : Bool
    let options  : Options

    struct Options: Encodable {
        let num_ctx      : Int    // context window
        let temperature  : Double
    }
}

private struct OllamaChunk: Decodable {
    struct Msg: Decodable { let role: String?; let content: String }
    let message : Msg?
    let done    : Bool
}

private struct OllamaTagsResponse: Decodable {
    struct ModelInfo: Decodable { let name: String }
    let models: [ModelInfo]
}

// MARK: - Service

@MainActor
final class OllamaService: ObservableObject {

    static let shared = OllamaService()

    // Ordered preference list. Setup tries each in turn until one pulls successfully.
    // gemma4:e4b = Gemma 4 Efficient 4B — fits ~3 GB, fast on M4 Apple Silicon.
    static let modelCandidates  = ["gemma4:e4b", "gemma4:e2b", "gemma3:4b"]
    static let baseURL          = "http://127.0.0.1:11434"

    // Set by OllamaSetupManager once a model is confirmed present.
    static var recommendedModel = "gemma4:e4b"

    // MARK: - Streaming chat

    /// Stream a chat response token by token, calling `onToken` for each delta.
    func streamChat(
        history: [ChatMessage],
        onToken : @escaping @MainActor (String) -> Void,
        onDone  : @escaping @MainActor ()       -> Void,
        onError : @escaping @MainActor (String) -> Void
    ) {
        let messages = history.map {
            OllamaRequest.Msg(role: $0.role.rawValue, content: $0.content)
        }
        let body = OllamaRequest(
            model   : Self.recommendedModel,
            messages: messages,
            stream  : true,
            options : .init(num_ctx: 8192, temperature: 0.7)
        )

        guard
            let url  = URL(string: "\(Self.baseURL)/api/chat"),
            let data = try? JSONEncoder().encode(body)
        else { onError("Could not build request."); return }

        var req         = URLRequest(url: url)
        req.httpMethod  = "POST"
        req.httpBody    = data
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        Task {
            do {
                let (stream, response) = try await URLSession.shared.bytes(for: req)
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    onError("Ollama returned an error. Is the model pulled?"); return
                }

                for try await line in stream.lines {
                    guard !line.isEmpty, let lineData = line.data(using: .utf8) else { continue }
                    if let chunk = try? JSONDecoder().decode(OllamaChunk.self, from: lineData) {
                        if let delta = chunk.message?.content, !delta.isEmpty {
                            onToken(delta)
                        }
                        if chunk.done { onDone(); return }
                    }
                }
                onDone()
            } catch {
                onError(error.localizedDescription)
            }
        }
    }
}
