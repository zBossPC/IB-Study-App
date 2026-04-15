import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var progress: ProgressStore
    @AppStorage("ibstudy.welcomeSplashCompleted") private var welcomeSplashCompleted = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                header
                themeSection
                preferencesSection
                dangerZone
            }
            .padding(28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.pageGradient.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Settings")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(.white)
            Text("Customize your study experience")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    // MARK: - Theme picker

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Theme", systemImage: "paintpalette.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                ForEach(AppTheme.allThemes) { theme in
                    themeCard(theme)
                }
            }
        }
        .padding(20)
        .glassPanel(tint: themeManager.current.accentCore, glow: .clear, radius: 22)
    }

    private func themeCard(_ theme: AppTheme) -> some View {
        let selected = themeManager.current.id == theme.id
        return Button { themeManager.apply(theme) } label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [theme.pageTop, theme.pageMid, theme.pageBottom],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(selected ? theme.accentCore : Color.white.opacity(0.1), lineWidth: selected ? 2 : 1)
                        )

                    HStack(spacing: 6) {
                        Circle().fill(theme.accentCore).frame(width: 10, height: 10)
                        Circle().fill(theme.accentGlow).frame(width: 10, height: 10)
                        Circle().fill(theme.pageTop).frame(width: 10, height: 10)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: theme.icon)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(selected ? theme.accentCore : .white.opacity(0.6))
                    Text(theme.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(selected ? .white : .white.opacity(0.7))
                }

                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(theme.accentCore)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selected ? theme.accentCore.opacity(0.12) : Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(selected ? theme.accentCore.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Preferences", systemImage: "gearshape.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Toggle(isOn: Binding(
                get: { !welcomeSplashCompleted },
                set: { welcomeSplashCompleted = !$0 }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Show welcome splash on next launch")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                    Text("Re-enables the first-launch screen")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .toggleStyle(.switch)
            .tint(themeManager.current.accentCore)
            .padding(14)
            .glassPanel(tint: .white, glow: .clear, radius: 14)
        }
        .padding(20)
        .glassPanel(tint: .white, glow: .clear, radius: 22)
    }

    // MARK: - Danger zone

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Data", systemImage: "externaldrive.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Button {
                progress.resetAll()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset all progress")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("XP, streaks, scores")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .foregroundStyle(Color.red)
                .padding(14)
            }
            .buttonStyle(.plain)
            .glassPanel(tint: Color.red, glow: .clear, radius: 14)
        }
        .padding(20)
        .glassPanel(tint: Color.red.opacity(0.5), glow: .clear, radius: 22)
    }
}
