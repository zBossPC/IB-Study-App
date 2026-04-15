import SwiftUI

struct GlossaryView: View {
    let terms: [GlossaryTerm]

    @State private var query = ""

    private var filtered: [GlossaryTerm] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return terms }
        return terms.filter {
            $0.term.lowercased().contains(q) || $0.definition.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Search glossary", text: $query)
                .textFieldStyle(.roundedBorder)
                .padding([.horizontal, .top], 20)
                .padding(.bottom, 12)

            List(filtered) { term in
                VStack(alignment: .leading, spacing: 6) {
                    Text(term.term)
                        .font(.headline)
                    Text(term.definition)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
                .listRowBackground(Color.clear)
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.06), Color.black.opacity(0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
