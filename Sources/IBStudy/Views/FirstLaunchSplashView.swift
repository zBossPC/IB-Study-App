import SwiftUI

/// Fullscreen first-launch experience: animated ambient glow, then content pops in; dismiss reveals the main UI with a spring “pop”.
struct FirstLaunchSplashView: View {
    @Binding var isPresented: Bool
    var accent: Color

    @State private var glowPhase: CGFloat = 0
    @State private var secondaryPulse: CGFloat = 0
    @State private var contentRevealed = false
    @State private var exitShrink = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Base — deep field
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.03, blue: 0.08),
                        Color(red: 0.04, green: 0.05, blue: 0.12),
                        Color(red: 0.02, green: 0.02, blue: 0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Large slow-moving glow orbs (breathing)
                glowBlob(
                    color: accent,
                    size: max(w, h) * 0.85,
                    center: CGPoint(x: w * 0.22, y: h * 0.35),
                    phase: glowPhase,
                    opacity: 0.38
                )
                glowBlob(
                    color: Color(red: 0.55, green: 0.35, blue: 1.0),
                    size: max(w, h) * 0.7,
                    center: CGPoint(x: w * 0.78, y: h * 0.55),
                    phase: glowPhase + 0.4,
                    opacity: 0.28
                )
                glowBlob(
                    color: Color(red: 0.2, green: 0.75, blue: 0.95),
                    size: max(w, h) * 0.55,
                    center: CGPoint(x: w * 0.5, y: h * 0.82),
                    phase: glowPhase + 0.75,
                    opacity: 0.22
                )

                // Fine shimmer ring (rotating soft highlight)
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                accent.opacity(0),
                                accent.opacity(0.55),
                                Color.white.opacity(0.15),
                                accent.opacity(0.45),
                                accent.opacity(0)
                            ],
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: min(w, h) * 0.72, height: min(w, h) * 0.72)
                    .blur(radius: 6)
                    .rotationEffect(.degrees(Double(glowPhase) * 120))
                    .opacity(0.35 + secondaryPulse * 0.2)

                // Vignette
                RadialGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    center: .center,
                    startRadius: min(w, h) * 0.15,
                    endRadius: max(w, h) * 0.85
                )

                // Foreground card — pops in after glow settles
                VStack(spacing: 22) {
                    MascotGuideView(mood: .celebrating, size: 120, showOrb: true, animated: true)
                        .shadow(color: accent.opacity(0.55), radius: 28, y: 8)

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
                        dismissSplash()
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
                .padding(36)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.35),
                                            accent.opacity(0.25),
                                            Color.white.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                )
                .shadow(color: accent.opacity(0.25), radius: 40, y: 18)
                .shadow(color: .black.opacity(0.45), radius: 32, y: 20)
                .padding(.horizontal, 32)
                .scaleEffect(contentRevealed ? (exitShrink ? 0.88 : 1) : 0.82)
                .opacity(contentRevealed ? (exitShrink ? 0 : 1) : 0)
                .offset(y: contentRevealed ? (exitShrink ? -20 : 0) : 24)
            }
            .frame(width: w, height: h)
            .contentShape(Rectangle())
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                glowPhase = 1
            }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                secondaryPulse = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                withAnimation(.spring(response: 0.52, dampingFraction: 0.68)) {
                    contentRevealed = true
                }
            }
        }
    }

    private func glowBlob(color: Color, size: CGFloat, center: CGPoint, phase: CGFloat, opacity: Double) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [color.opacity(opacity), color.opacity(0.06), .clear],
                    center: .center,
                    startRadius: size * 0.08,
                    endRadius: size * 0.5
                )
            )
            .frame(width: size, height: size * 0.92)
            .blur(radius: 42)
            .position(
                x: center.x + sin(phase * .pi * 2) * 18,
                y: center.y + cos(phase * .pi * 2) * 14
            )
    }

    private func dismissSplash() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
            exitShrink = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(.easeOut(duration: 0.2)) {
                isPresented = false
            }
        }
    }
}
