import Foundation
import SwiftUI

@MainActor
final class ContentStore: ObservableObject {
    @Published private(set) var subjects: [Subject] = []
    @Published var selectedSubjectId: String = "economics"
    @Published private(set) var loadError: String?

    // Convenience for views that haven't migrated to multi-subject yet
    var payload: UnitPayload? { selectedSubject?.payload }
    var selectedSubject: Subject? { subjects.first { $0.id == selectedSubjectId } }

    init() { load() }

    func load() {
        var loaded: [Subject] = []
        var errors: [String] = []

        let manifest: [(file: String, id: String, title: String, subtitle: String, icon: String, color: Color)] = [
            ("unit3",          "economics",       "Economics", "AP Unit 3 · Micro",      "chart.bar.fill", .blue),
            ("physics_static", "physics-static",  "Physics",   "Static Electricity",     "bolt.fill",      .orange),
        ]

        for entry in manifest {
            guard let url = Self.urlForContentJSON(named: entry.file) else {
                errors.append("Missing \(entry.file).json")
                continue
            }
            do {
                let data = try Data(contentsOf: url)
                let p = try JSONDecoder().decode(UnitPayload.self, from: data)
                loaded.append(Subject(id: entry.id, title: entry.title, subtitle: entry.subtitle,
                                      icon: entry.icon, color: entry.color, payload: p))
            } catch {
                errors.append("\(entry.file): \(error.localizedDescription)")
            }
        }

        subjects = loaded
        loadError = errors.isEmpty ? nil : errors.joined(separator: "\n")

        // Default to first loaded subject
        if selectedSubjectId.isEmpty, let first = loaded.first { selectedSubjectId = first.id }
    }

    /// Resolves JSON from the SwiftPM resource bundle (`Bundle.module`). Falls back to
    /// `Contents/Resources/` for older app layouts that copied JSON next to the icon.
    private static func urlForContentJSON(named name: String) -> URL? {
        if let u = Bundle.module.url(forResource: name, withExtension: "json") { return u }
        if let u = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "IBStudy_IBStudy.bundle") {
            return u
        }
        return Bundle.main.url(forResource: name, withExtension: "json")
    }
}
