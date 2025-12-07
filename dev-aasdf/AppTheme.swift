import SwiftUI

enum AppTheme {
    // Apple-like vibrant accents tailored for dark appearance
    static let accent: Color = .cyan
    static let accentSecondary: Color = .indigo
    static let success: Color = .green
    static let warning: Color = .orange
    static let error: Color = .red

    // A premium, Apple-like background with depth
    static var background: some View {
        ZStack {
            // Base subtle radial glow
            RadialGradient(
                colors: [Color.black, Color.black.opacity(0.6)],
                center: .center,
                startRadius: 0,
                endRadius: 800
            )
            // Vibrant mesh-like overlays
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.35),
                    Color.cyan.opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.25),
                    Color.pink.opacity(0.20)
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        }
    }
}

extension View {
    // Apply global chrome consistent with Liquid Glass design
    func appChrome() -> some View {
        self
            .tint(AppTheme.accent)
            .buttonStyle(.glass)
    }

    // Apply a full-bleed dynamic background
    func appBackground() -> some View {
        self
            .background {
                AppTheme.background
                    .ignoresSafeArea()
            }
    }
}
