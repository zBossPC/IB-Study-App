import SwiftUI

struct SidebarFooterPanel: View {
    @EnvironmentObject private var progress: ProgressStore
    @Binding var showAchievements: Bool

    private var levelSpan: (current: Int, next: Int) {
        progress.xpIntoLevel(for: progress.xp)
    }

    private var xpFraction: CGFloat {
        let span = levelSpan
        return CGFloat(span.current) / CGFloat(max(span.next, 1))
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(GlassTheme.xpGradient)
                    Circle()
                        .strokeBorder(Color.white.opacity(0.26), lineWidth: 1)
                    VStack(spacing: 0) {
                        Text("LV")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundStyle(.white.opacity(0.82))
                        Text("\(progress.level(for: progress.xp))")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("Scholar Trail")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 0)
                        Text("\(progress.xp) XP")
                            .font(.caption.monospacedDigit().weight(.semibold))
                            .foregroundStyle(.primary)
                    }

                    GameProgressBar(progress: xpFraction.doubleValue, tint: GlassTheme.xpColor, height: 8)

                    Text("\(levelSpan.current) / \(levelSpan.next) to next level")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                Label(
                    progress.streakDays > 0 ? "\(progress.streakDays) day streak" : "Start your streak",
                    systemImage: "flame.fill"
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(progress.streakDays > 0 ? GlassTheme.streakColor : .secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            progress.streakDays > 0
                                ? GlassTheme.streakColor.opacity(0.14)
                                : Color.white.opacity(0.06)
                        )
                )

                Spacer(minLength: 0)

                Button {
                    showAchievements = true
                } label: {
                    Label("Rewards", systemImage: "trophy.fill")
                        .font(.caption.weight(.bold))
                }
                .buttonStyle(GameSecondaryButtonStyle(tint: GlassTheme.xpColor))
                .help("Achievements")
            }
        }
        .padding(14)
        .glassPanel(tint: GlassTheme.mascotCore, glow: GlassTheme.mascotGlow, radius: 20)
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

private extension CGFloat {
    var doubleValue: Double { Double(self) }
}
