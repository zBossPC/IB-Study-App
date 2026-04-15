import SwiftUI

@MainActor
final class StudyContext: ObservableObject {
    static let shared = StudyContext()

    @Published var currentSubjectTitle: String = ""
    @Published var currentSectionTitle: String = ""
    @Published var currentSectionId: String = ""
    @Published var currentLessonTitle: String = ""
    @Published var currentLessonSnippet: String = ""

    var contextBlock: String {
        var parts: [String] = []
        if !currentSubjectTitle.isEmpty {
            parts.append("Subject: \(currentSubjectTitle)")
        }
        if !currentSectionTitle.isEmpty {
            parts.append("Section: \(currentSectionTitle)")
        }
        if !currentLessonTitle.isEmpty {
            parts.append("Lesson: \(currentLessonTitle)")
        }
        if !currentLessonSnippet.isEmpty {
            let trimmed = String(currentLessonSnippet.prefix(600))
            parts.append("Lesson content preview:\n\(trimmed)")
        }
        guard !parts.isEmpty else { return "" }
        return "\n\nThe student is currently studying:\n" + parts.joined(separator: "\n")
    }

    func update(subject: String, section: String, sectionId: String, lesson: String = "", snippet: String = "") {
        currentSubjectTitle = subject
        currentSectionTitle = section
        currentSectionId = sectionId
        currentLessonTitle = lesson
        currentLessonSnippet = snippet
    }

    func clear() {
        currentSubjectTitle = ""
        currentSectionTitle = ""
        currentSectionId = ""
        currentLessonTitle = ""
        currentLessonSnippet = ""
    }
}
