import SwiftUI

/// One-time welcome overlay shown on the first launch after install.
struct FirstLaunchSplashView: View {
    @Binding var isPresented: Bool
    var accent: Color

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                MascotGuideView(mood: .celebrating, size: 120, showOrb: true, animated: true)

                VStack(spacing: 8) {
                    Text("Welcome to IBStudy")
                        .font(.title.weight(.black))
                        .foregroundStyle(.white)
                    Text("Your path, lessons, drills, and AI tutor—ready when you are.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.78))
                        .frame(maxWidth: 420)
                }

                Button {
                    withAnimation(.easeOut(duration: 0.22)) {
                        isPresented = false
                    }
                } label: {
                    Text("Let’s go")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(accent)
                .controlSize(.large)
                .frame(maxWidth: 280)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 28, y: 14)
            .padding(40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}
