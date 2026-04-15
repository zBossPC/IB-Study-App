import SwiftUI

struct AccountsView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [themeManager.current.accentCore.opacity(0.2), .clear],
                            center: .center, startRadius: 20, endRadius: 100
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: "person.crop.circle.badge.clock.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(themeManager.current.accentCore.opacity(0.6))
            }

            VStack(spacing: 8) {
                Text("Accounts")
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(.white)

                Text("Coming Soon")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(themeManager.current.accentCore)
            }

            Text("Cloud sync, study groups, and shared progress are currently in development. Stay tuned for a future update!")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)

            HStack(spacing: 12) {
                featureChip(icon: "cloud.fill", label: "Cloud Sync")
                featureChip(icon: "person.2.fill", label: "Study Groups")
                featureChip(icon: "chart.bar.fill", label: "Leaderboards")
            }

            Spacer()

            Text("This feature is under active development")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.pageGradient.ignoresSafeArea())
    }

    private func featureChip(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(label)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(themeManager.current.accentCore.opacity(0.7))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(themeManager.current.accentCore.opacity(0.08), in: Capsule(style: .continuous))
        .overlay(Capsule(style: .continuous).strokeBorder(themeManager.current.accentCore.opacity(0.2), lineWidth: 1))
    }
}
