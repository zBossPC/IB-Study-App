import Foundation
import SwiftUI

// MARK: - Subject (top-level container shown in the sidebar picker)

struct Subject: Identifiable {
    let id: String          // "economics", "physics-static"
    let title: String       // "Economics"
    let subtitle: String    // "AP Unit 3 · Micro"
    let icon: String        // SF Symbol name
    let color: Color
    let payload: UnitPayload
}

// MARK: - Content models

struct UnitPayload: Codable, Sendable, Identifiable {
    var id: String { unitId }
    let unitId: String
    let title: String
    let sections: [ContentSection]
    let glossary: [GlossaryTerm]
}

struct ContentSection: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let title: String
    let lessons: [Lesson]
    let flashcards: [Flashcard]
    let questions: [MCQuestion]
}

struct Lesson: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let title: String
    let bodyMarkdown: String
}

struct Flashcard: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let front: String
    let back: String
}

struct MCQuestion: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let prompt: String
    let choices: [String]
    let correctIndex: Int
    let explanation: String
}

struct GlossaryTerm: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let term: String
    let definition: String
}
