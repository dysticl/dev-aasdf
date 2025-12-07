//
//  LiquidGlassComponents.swift
//  dev-aasdf
//
//  Solo Leveling Design System - Dark Fantasy RPG UI
//

import SwiftUI

// MARK: - Design System Constants

enum DesignSystem {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    enum CornerRadius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let pill: CGFloat = 100
    }

    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xl: CGFloat = 32
    }
}

// MARK: - Solo Leveling Color Palette

enum SoloColors {
    // Dark Fantasy Base - Pure black (#000000) and deep grey (#1A1A1A)
    static let darkBackground = Color(hex: "000000")
    static let cardBackground = Color(hex: "1A1A1A")
    static let surface = Color(hex: "0D0D0D")

    // Neon Accents - as specified
    static let neonBlue = Color(hex: "00BFFF")  // Primary accent
    static let neonViolet = Color(hex: "8A2BE2")  // Secondary accent
    static let xpGold = Color(hex: "FFD700")  // XP/Rewards
    static let successGreen = Color(hex: "10B981")  // Success states
    static let dangerRed = Color(hex: "EF4444")  // Danger/Critical
    static let warningOrange = Color(hex: "F59E0B")  // Warnings

    // Backward compatibility aliases
    static let electricBlue = neonBlue
    static let hunterPurple = neonViolet

    // Text colors with proper contrast (4.5:1 minimum)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
}

// MARK: - Solo Leveling Gradients

struct LiquidGlassGradients {
    // Main background gradient
    static let background = LinearGradient(
        colors: [SoloColors.darkBackground, SoloColors.cardBackground],
        startPoint: .top,
        endPoint: .bottom
    )

    // XP Gold gradient for rewards
    static let xpGold = LinearGradient(
        colors: [SoloColors.xpGold, .orange],
        startPoint: .leading,
        endPoint: .trailing
    )

    // Primary neon gradient
    static let primary = LinearGradient(
        colors: [SoloColors.neonBlue, SoloColors.neonViolet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Hunter rank gradient
    static let hunterRank = LinearGradient(
        colors: [.cyan, SoloColors.neonBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Level up celebration
    static let levelUp = LinearGradient(
        colors: [SoloColors.xpGold, SoloColors.warningOrange],
        startPoint: .top,
        endPoint: .bottom
    )

    // Success gradient
    static let success = LinearGradient(
        colors: [SoloColors.successGreen, .mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Danger/Critical gradient
    static let danger = LinearGradient(
        colors: [SoloColors.dangerRed, .pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Glass border effect
    static let glassBorder = LinearGradient(
        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Priority Badge

struct PriorityBadge: View {
    let priority: String

    var badgeColor: Color {
        switch priority.lowercased() {
        case "critical": return SoloColors.dangerRed
        case "high": return SoloColors.warningOrange
        case "medium": return SoloColors.xpGold
        default: return .gray
        }
    }

    var body: some View {
        Text(priority.uppercased())
            .font(.system(size: 9, weight: .black))
            .tracking(1)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                Capsule().fill(badgeColor)
            )
            .shadow(color: badgeColor.opacity(0.5), radius: 4)
    }
}

// MARK: - Floating Action Button

struct FloatingActionButton: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(SoloColors.neonBlue.opacity(0.3), lineWidth: 2)
                    .frame(width: 72, height: 72)

                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [SoloColors.neonBlue, SoloColors.neonViolet],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: SoloColors.neonBlue.opacity(0.6), radius: 15, y: 5)
            .shadow(color: SoloColors.neonViolet.opacity(0.4), radius: 25, y: 10)
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Liquid Glass Card Modifier

struct LiquidGlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.medium
    var statusColor: Color = .clear
    var padding: CGFloat = DesignSystem.Spacing.lg

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(SoloColors.cardBackground.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        statusColor == .clear
                            ? Color.white.opacity(0.1)
                            : statusColor.opacity(0.4),
                        lineWidth: 1
                    )
            )
            .shadow(color: statusColor.opacity(0.2), radius: 10, y: 4)
    }
}

extension View {
    func liquidGlassCard(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.medium,
        statusColor: Color = .clear,
        padding: CGFloat = DesignSystem.Spacing.lg
    ) -> some View {
        modifier(
            LiquidGlassCardModifier(
                cornerRadius: cornerRadius,
                statusColor: statusColor,
                padding: padding
            ))
    }
}

// MARK: - Neon Glow Modifier

struct NeonGlowModifier: ViewModifier {
    var color: Color = SoloColors.neonBlue
    var radius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius / 2)
            .shadow(color: color.opacity(0.4), radius: radius)
    }
}

extension View {
    func neonGlow(color: Color = SoloColors.neonBlue, radius: CGFloat = 8) -> some View {
        modifier(NeonGlowModifier(color: color, radius: radius))
    }

    // Alias for backward compatibility
    func glowEffect(color: Color = SoloColors.neonBlue, radius: CGFloat = 10) -> some View {
        modifier(NeonGlowModifier(color: color, radius: radius))
    }
}

// MARK: - HUD Border Modifier

struct HUDBorderModifier: ViewModifier {
    var color: Color = SoloColors.neonBlue
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.medium

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color.opacity(0.5), lineWidth: 1.5)
            )
            .shadow(color: color.opacity(0.25), radius: 8)
    }
}

extension View {
    func hudBorder(
        color: Color = SoloColors.neonBlue, cornerRadius: CGFloat = DesignSystem.CornerRadius.medium
    ) -> some View {
        modifier(HUDBorderModifier(color: color, cornerRadius: cornerRadius))
    }

    func glassEffect(material: Material = .ultraThin, radius: CGFloat) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: radius)
                .fill(material)
        )
    }
}

// MARK: - Ambient Glow Background (Legacy Support)

struct AmbientGlowBackground: View {
    var primaryColor: Color = SoloColors.neonBlue
    var secondaryColor: Color = SoloColors.neonViolet
    var tertiaryColor: Color = SoloColors.xpGold

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Primary glow - top left
            RadialGradient(
                colors: [primaryColor.opacity(0.15), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 350
            )

            // Secondary glow - bottom right
            RadialGradient(
                colors: [secondaryColor.opacity(0.10), Color.clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
        }
    }
}
