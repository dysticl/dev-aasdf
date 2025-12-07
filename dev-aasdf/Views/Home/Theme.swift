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
            .shadow(color: Color.violetGlow.opacity(0.6), radius: 12, y: 4)
            .shadow(color: Color.violetGlow.opacity(0.3), radius: 24, y: 8)
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
