//
//  LiquidGlassComponents.swift
//  dev-aasdf
//
//  Solo Leveling UI Design System with iOS 26 Liquid Glass aesthetics
//

import SwiftUI

// MARK: - Design System

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

// MARK: - Color Extension for Hex

extension Color {
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

// MARK: - Solo Leveling Color Palette

enum SoloColors {
    // Base colors
    static let darkBackground = Color(hex: "0F1419")
    static let cardBackground = Color(hex: "1A1F2E")
    static let surface = Color(hex: "252B3B")

    // Neon accents
    static let electricBlue = Color(hex: "00D4FF")
    static let hunterPurple = Color(hex: "8B5CF6")
    static let xpGold = Color(hex: "FFB800")
    static let successGreen = Color(hex: "10B981")
    static let dangerRed = Color(hex: "EF4444")
    static let warningOrange = Color(hex: "F59E0B")

    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
}

// MARK: - Liquid Glass Gradients

struct LiquidGlassGradients {
    static let background = LinearGradient(
        colors: [SoloColors.darkBackground, SoloColors.cardBackground],
        startPoint: .top,
        endPoint: .bottom
    )

    static let xpGold = LinearGradient(
        colors: [SoloColors.xpGold, .yellow],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let primary = LinearGradient(
        colors: [SoloColors.electricBlue, SoloColors.hunterPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let hunterRank = LinearGradient(
        colors: [.cyan, SoloColors.electricBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let levelUp = LinearGradient(
        colors: [SoloColors.xpGold, SoloColors.warningOrange],
        startPoint: .top,
        endPoint: .bottom
    )

    static let success = LinearGradient(
        colors: [SoloColors.successGreen, .mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let danger = LinearGradient(
        colors: [SoloColors.dangerRed, .pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glassBorder = LinearGradient(
        colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let darkOverlay = LinearGradient(
        colors: [Color.black.opacity(0.6), Color.clear],
        startPoint: .bottom,
        endPoint: .top
    )
}

// MARK: - Ambient Glow Background

struct AmbientGlowBackground: View {
    var primaryColor: Color = SoloColors.electricBlue
    var secondaryColor: Color = SoloColors.hunterPurple
    var tertiaryColor: Color = SoloColors.xpGold

    var body: some View {
        ZStack {
            LiquidGlassGradients.background.ignoresSafeArea()

            // Primary glow - top left
            Circle()
                .fill(primaryColor.opacity(0.10))
                .blur(radius: 120)
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)

            // Secondary glow - bottom right
            Circle()
                .fill(secondaryColor.opacity(0.08))
                .blur(radius: 100)
                .frame(width: 250, height: 250)
                .offset(x: 150, y: 300)

            // Tertiary glow - center accent
            Circle()
                .fill(tertiaryColor.opacity(0.05))
                .blur(radius: 80)
                .frame(width: 200, height: 200)
                .offset(x: 50, y: 100)
        }
    }
}

// MARK: - Stat Mini Card (Enhanced)

struct StatMiniCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    init(title: String, value: String, color: Color, icon: String = "") {
        self.title = title
        self.value = value
        self.color = color
        self.icon = icon
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: DesignSystem.IconSize.medium))
                    .foregroundColor(color.opacity(0.8))
            }

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(SoloColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Status Tab Button (Enhanced)

struct StatusTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : SoloColors.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    Group {
                        if isSelected {
                            LiquidGlassGradients.primary.opacity(0.3)
                        } else {
                            Color.clear
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected
                                ? SoloColors.electricBlue.opacity(0.5) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
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
        Text(priority.capitalized)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                Capsule().fill(badgeColor)
            )
            .shadow(color: badgeColor.opacity(0.4), radius: 4, y: 2)
    }
}

// MARK: - Floating Action Button (Enhanced)

struct FloatingActionButton: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 68, height: 68)
                .background(
                    Circle()
                        .fill(LiquidGlassGradients.primary)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: SoloColors.electricBlue.opacity(0.5), radius: 20, x: 0, y: 8)
                .shadow(color: SoloColors.hunterPurple.opacity(0.3), radius: 30, x: 0, y: 15)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
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
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)

                    if statusColor != .clear {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [statusColor.opacity(0.15), statusColor.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
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

// MARK: - Glass Button Style

struct GlassButtonStyle: ButtonStyle {
    var color: Color = SoloColors.electricBlue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(
                        configuration.isPressed
                            ? color.opacity(0.8)
                            : color
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(
                color: color.opacity(0.4), radius: configuration.isPressed ? 5 : 10,
                y: configuration.isPressed ? 2 : 5
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Glow Text Modifier

struct GlowTextModifier: ViewModifier {
    var color: Color = SoloColors.electricBlue
    var radius: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
    }
}

extension View {
    func glowEffect(color: Color = SoloColors.electricBlue, radius: CGFloat = 10) -> some View {
        modifier(GlowTextModifier(color: color, radius: radius))
    }
}
