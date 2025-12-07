import SwiftUI

// MARK: - Solo Leveling Theme
// Dark-Fantasy-RPG-Ästhetik mit rationaler Motivation

enum AppTheme {
    // Solo Leveling Neon Accents
    static let accent: Color = Color(hex: "00BFFF")  // Neon-Blau (Deep Sky Blue)
    static let accentSecondary: Color = Color(hex: "8A2BE2")  // Violett (Blue Violet)
    static let xpGold: Color = Color(hex: "FFD700")  // XP Gold
    static let success: Color = Color(hex: "10B981")  // Emerald Green
    static let warning: Color = Color(hex: "F59E0B")  // Amber
    static let error: Color = Color(hex: "EF4444")  // Red

    // Dark Fantasy Background - Pure Black mit subtilen Glows
    static var background: some View {
        ZStack {
            // Dark Fantasy Base
            Color.shadowBackground

            // Subtle neon-blue glow - top
            RadialGradient(
                colors: [
                    Color(hex: "00BFFF").opacity(0.12),
                    Color.clear,
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )

            // Subtle violet glow - bottom
            RadialGradient(
                colors: [
                    Color(hex: "8A2BE2").opacity(0.08),
                    Color.clear,
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 350
            )
        }
    }

    // HUD-style card background
    static let cardBackground: Color = Color(hex: "1A1A1A")
    static let surfaceBackground: Color = Color(hex: "0D0D0D")
}

// MARK: - Solo Leveling Typography

enum SoloTypography {
    // Headers with glow effect
    static func header(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: AppTheme.accent.opacity(0.5), radius: 8)
            .shadow(color: AppTheme.accent.opacity(0.3), radius: 15)
    }

    static func subheader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.white.opacity(0.9))
    }

    static func questTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
    }

    static func statValue(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 32, weight: .black, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accentSecondary],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: AppTheme.accent.opacity(0.4), radius: 6)
    }
}

// MARK: - View Extensions

extension View {
    // Apply global chrome consistent with Solo Leveling design
    func appChrome() -> some View {
        self
            .tint(AppTheme.accent)
            .preferredColorScheme(.dark)
    }

    // Apply a full-bleed dynamic background
    func appBackground() -> some View {
        self
            .background {
                AppTheme.background
                    .ignoresSafeArea()
            }
    }

    // HUD-style neon border glow
    func neonBorder(color: Color = AppTheme.accent, radius: CGFloat = 16) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(color.opacity(0.6), lineWidth: 1.5)
            )
            .shadow(color: color.opacity(0.3), radius: 8)
    }

    // Quest card style
    func questCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.cardBackground.opacity(0.85))
            )
            .neonBorder(color: AppTheme.accent.opacity(0.4))
    }

    // Glow text effect
    func soloGlow(color: Color = AppTheme.accent, radius: CGFloat = 8) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius / 2)
            .shadow(color: color.opacity(0.4), radius: radius)
    }
}

// MARK: - Color Extension

extension Color {
    // Shadow Theme Colors
    static let shadowBackground = Color(hex: "0D1B2A")
    static let violetGlow = Color(hex: "512DA8")
    static let shadowText = Color.white.opacity(0.9)
    static let shadowTextSecondary = Color.white.opacity(0.6)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
