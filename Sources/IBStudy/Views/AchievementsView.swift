import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        List(AchievementDefinition.all) { def in
            HStack(spacing: 14) {
                Image(systemName: def.symbol)
                    .font(.title2)
                    .foregroundStyle(progress.unlockedAchievementIds.contains(def.id) ? Color.accentColor : Color.secondary.opacity(0.35))
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text(def.title)
                        .font(.headline)
                    Text(def.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if progress.unlockedAchievementIds.contains(def.id) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Achievements")
    }
}
