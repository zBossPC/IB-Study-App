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
            ("unit3",                     "economics",         "Economics", "AP Unit 3 · Micro",                                 "chart.bar.fill",               .blue),
            ("econ_unit4",                "economics-unit4",   "Economics", "AP Unit 4 · Imperfect Competition",                  "building.columns.fill",        .indigo),
            ("physics_static",            "physics-static",    "Physics",   "Static Electricity",                                "bolt.fill",                    .orange),
            ("physics_magnetism",         "physics-magnetism", "Physics",   "Magnetism and Electromagnetism",                    "wave.3.right.circle.fill",     .mint),
            ("history_americas_coldwar",  "history-americas",  "History",   "Americas · Cold War & Social Movements (1945-2001)", "book.pages.fill",              .brown),
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

    /// Resolves course JSON. Prefer flat files in the app’s `Resources/` folder (reliable in
    /// distributed `.app` bundles), then SwiftPM’s `Bundle.module`, then explicit paths.
    private static func urlForContentJSON(named name: String) -> URL? {
        let fm = FileManager.default
        let fileName = "\(name).json"

        func firstExisting(_ urls: [URL]) -> URL? {
            for u in urls where fm.fileExists(atPath: u.path) { return u }
            return nil
        }

        // 1) Standard macOS app Resources (sync scripts copy JSON here).
        if let u = Bundle.main.url(forResource: name, withExtension: "json") {
            if fm.fileExists(atPath: u.path) { return u }
        }

        // 2) SwiftPM bundle (development + packaged IBStudy_IBStudy.bundle).
        if let u = Bundle.module.url(forResource: name, withExtension: "json") {
            if fm.fileExists(atPath: u.path) { return u }
        }

        // 3) Nested resource bundle under Resources.
        if let u = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "IBStudy_IBStudy.bundle") {
            if fm.fileExists(atPath: u.path) { return u }
        }

        let contents = Bundle.main.bundleURL
        var paths: [URL] = [
            contents.appendingPathComponent("Resources/\(fileName)"),
            contents.appendingPathComponent("Resources/IBStudy_IBStudy.bundle/\(fileName)"),
            contents.appendingPathComponent("IBStudy_IBStudy.bundle/\(fileName)"),
        ]

        // 4) If `bundleURL` is the `.app` root (some contexts), try Contents/…
        if contents.pathExtension == "app" {
            paths.append(contents.appendingPathComponent("Contents/Resources/\(fileName)"))
            paths.append(contents.appendingPathComponent("Contents/Resources/IBStudy_IBStudy.bundle/\(fileName)"))
            paths.append(contents.appendingPathComponent("Contents/IBStudy_IBStudy.bundle/\(fileName)"))
        }

        return firstExisting(paths)
    }
}
