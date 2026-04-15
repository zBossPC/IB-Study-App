import Foundation
import SwiftUI

enum SectionJourneyState {
    case locked
    case active
    case explored
    case mastered
    case perfect

    var label: String {
        switch self {
        case .locked:   return "Locked"
        case .active:   return "Next Up"
        case .explored: return "Started"
        case .mastered: return "Cleared"
        case .perfect:  return "Perfect"
        }
    }
}

/// Progression and feedback loop: immediate rewards, visible growth, light challenge (inspired by game-design practice).
@MainActor
final class ProgressStore: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published private(set) var xp: Int
    @Published private(set) var streakDays: Int
    @Published private(set) var lastStudyDay: String?
    @Published private(set) var exploredSectionIds: Set<String>
    @Published private(set) var quizBestBySection: [String: Int]
    @Published private(set) var unlockedAchievementIds: Set<String>

    init() {
        xp = defaults.integer(forKey: Keys.xp)
        streakDays = defaults.object(forKey: Keys.streak) == nil ? 0 : defaults.integer(forKey: Keys.streak)
        lastStudyDay = defaults.string(forKey: Keys.lastDay)
        exploredSectionIds = Set(defaults.stringArray(forKey: Keys.explored) ?? [])
        quizBestBySection = Self.decodeDict(defaults.string(forKey: Keys.quizBest))
        unlockedAchievementIds = Set(defaults.stringArray(forKey: Keys.achievements) ?? [])
    }

    func recordExploreOpened(sectionId: String) {
        let wasNew = !exploredSectionIds.contains(sectionId)
        exploredSectionIds.insert(sectionId)
        defaults.set(Array(exploredSectionIds), forKey: Keys.explored)
        if wasNew {
            awardXP(5, reason: "explore")
        }
        refreshStreakIfNeeded()
        unlockIfNeeded(
            "explorer_all",
            condition: exploredSectionIds.isSuperset(of: Set(ExploreRegistry.explorableSectionIds))
        )
    }

    @discardableResult
    func recordQuizCompleted(sectionId: String, correct: Int, total: Int) -> Int {
        let prev = quizBestBySection[sectionId] ?? -1
        if correct > prev {
            quizBestBySection[sectionId] = correct
            defaults.set(Self.encodeDict(quizBestBySection), forKey: Keys.quizBest)
        }
        let base = 10 * correct
        let bonus = correct == total ? 25 : 0
        let gained = base + bonus
        awardXP(gained, reason: "quiz")
        refreshStreakIfNeeded()
        unlockIfNeeded("first_quiz", condition: true)
        unlockIfNeeded("perfect_quiz", condition: correct == total && total > 0)
        return gained
    }

    @discardableResult
    func recordFlashcardReview(sectionId _: String, total: Int) -> Int {
        let gained = max(12, total * 3)
        awardXP(gained, reason: "flashcards")
        refreshStreakIfNeeded()
        return gained
    }

    func level(for xp: Int) -> Int { 1 + xp / 100 }

    func xpIntoLevel(for xp: Int) -> (current: Int, next: Int) {
        let into = xp % 100
        return (into, 100)
    }

    func completionRatio(for section: ContentSection) -> Double {
        guard !section.questions.isEmpty else {
            return exploredSectionIds.contains(section.id) ? 1 : 0
        }
        let best = quizBestBySection[section.id] ?? 0
        return Double(best) / Double(max(section.questions.count, 1))
    }

    func journeyState(for section: ContentSection, in orderedSections: [ContentSection]) -> SectionJourneyState {
        if let best = quizBestBySection[section.id], !section.questions.isEmpty {
            return best >= section.questions.count ? .perfect : .mastered
        }
        if exploredSectionIds.contains(section.id) {
            return .explored
        }
        return recommendedSection(in: orderedSections)?.id == section.id ? .active : .locked
    }

    func recommendedSection(in orderedSections: [ContentSection]) -> ContentSection? {
        for section in orderedSections {
            switch journeyStateSnapshot(for: section) {
            case .locked, .active, .explored:
                return section
            case .mastered, .perfect:
                continue
            }
        }
        return orderedSections.first
    }

    func completedSectionCount(in sections: [ContentSection]) -> Int {
        sections.filter {
            let state = journeyState(for: $0, in: sections)
            return state == .mastered || state == .perfect
        }.count
    }

    func resetAll() {
        xp = 0; streakDays = 0; lastStudyDay = nil
        exploredSectionIds = []; quizBestBySection = [:]; unlockedAchievementIds = []
        for key in [Keys.xp, Keys.streak, Keys.lastDay, Keys.explored, Keys.quizBest, Keys.achievements] {
            defaults.removeObject(forKey: key)
        }
    }

    private func awardXP(_ amount: Int, reason: String) {
        guard amount > 0 else { return }
        xp += amount
        defaults.set(xp, forKey: Keys.xp)
        unlockIfNeeded("scholar_50", condition: xp >= 200)
    }

    private func unlockIfNeeded(_ id: String, condition: Bool) {
        guard condition, !unlockedAchievementIds.contains(id) else { return }
        unlockedAchievementIds.insert(id)
        defaults.set(Array(unlockedAchievementIds), forKey: Keys.achievements)
        awardXP(15, reason: "achievement")
    }

    private func refreshStreakIfNeeded() {
        let cal = Calendar.current
        let today = Self.dayString(for: Date())
        if lastStudyDay == today { return }
        if let last = lastStudyDay,
           let lastDate = Self.date(from: last),
           let yesterday = cal.date(byAdding: .day, value: -1, to: Date()),
           Self.dayString(for: lastDate) == Self.dayString(for: yesterday) {
            streakDays += 1
        } else if lastStudyDay != nil {
            streakDays = 1
        } else {
            streakDays = 1
        }
        lastStudyDay = today
        defaults.set(streakDays, forKey: Keys.streak)
        defaults.set(today, forKey: Keys.lastDay)
    }

    private enum Keys {
        static let xp = "econstudy.xp"
        static let streak = "econstudy.streak"
        static let lastDay = "econstudy.lastDay"
        static let explored = "econstudy.explored"
        static let quizBest = "econstudy.quizBest"
        static let achievements = "econstudy.achievements"
    }

    private static func dayString(for date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private static func date(from day: String) -> Date? {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: day)
    }

    private static func encodeDict(_ d: [String: Int]) -> String {
        (try? JSONEncoder().encode(d))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    private static func decodeDict(_ s: String?) -> [String: Int] {
        guard let s, let data = s.data(using: .utf8),
              let d = try? JSONDecoder().decode([String: Int].self, from: data) else { return [:] }
        return d
    }

    private func journeyStateSnapshot(for section: ContentSection) -> SectionJourneyState {
        if let best = quizBestBySection[section.id], !section.questions.isEmpty {
            return best >= section.questions.count ? .perfect : .mastered
        }
        if exploredSectionIds.contains(section.id) {
            return .explored
        }
        return .locked
    }
}

enum ExploreRegistry {
    static let explorableSectionIds: [String] = [
        "production", "short-run-costs", "long-run-costs", "cost-revenue-profit",
        "perfect-competition", "monopoly", "monopolistic-competition"
    ]

    static func hasExplore(sectionId: String) -> Bool {
        explorableSectionIds.contains(sectionId)
    }
}

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let symbol: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first_quiz", title: "First challenge", description: "Complete any section quiz.", symbol: "flag.checkered"),
        AchievementDefinition(id: "perfect_quiz", title: "Flawless", description: "Get every question right in a quiz.", symbol: "star.fill"),
        AchievementDefinition(id: "explorer_all", title: "Lab rat", description: "Open every interactive lab in Unit 3.", symbol: "atom"),
        AchievementDefinition(id: "scholar_50", title: "Scholar", description: "Reach 200 lifetime XP.", symbol: "graduationcap.fill")
    ]
}
