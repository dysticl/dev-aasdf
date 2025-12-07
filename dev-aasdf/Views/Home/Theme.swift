//
//  Theme.swift
//  Shadow Monarch - Solo Leveling Theme
//
//  Minimalist dark fantasy aesthetic with Liquid Glass
//

import SwiftUI

// MARK: - Shadow Theme Colors

extension Color {
    // Dark Fantasy Background
    static let shadowBackground = Color(hex: "#0D1B2A")
    
    // Deep Violet Accent
    static let violetGlow = Color(hex: "#512DA8")
    
    // Text
    static let shadowText = Color.white.opacity(0.9)
    static let shadowTextSecondary = Color.white.opacity(0.6)
    
    // Helper for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
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

// MARK: - Liquid Glass Modifiers

extension View {
    /// Applies perfect Liquid Glass effect with dark overlay
    func liquidGlass(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.shadowBackground.opacity(0.7))
                    )
                    .blur(radius: 10)
            )
    }
    
    /// Violet glow effect for progress bars and accents
    func violetGlow() -> some View {
        self
            .shadow(color: .violetGlow.opacity(0.6), radius: 12, y: 4)
            .shadow(color: .violetGlow.opacity(0.3), radius: 24, y: 8)
    }
}

// MARK: - Shared App Theme

struct ShadowTheme {
    static func applyGlobalTheme() {
        // TabBar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.shadowBackground.opacity(0.3))
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
