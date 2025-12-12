//
//  RewardComponents.swift
//  dev-aasdf
//
//  Adaptive Reward System UI Components
//  Solo Leveling + Liquid Glass Design
//

import SwiftUI

// MARK: - Reward Design System

enum RewardColors {
    static let backgroundDark = Color(hex: "050510")
    static let backgroundMid = Color(hex: "0A0A1A")
    static let accentBlue = Color(hex: "4A9EFF")
    static let accentViolet = Color(hex: "8B5CF6")
    static let accentPurple = Color(hex: "A855F7")
    static let glowBlue = Color(hex: "4A9EFF").opacity(0.4)
    static let glowViolet = Color(hex: "8B5CF6").opacity(0.4)
    static let cooldownOrange = Color(hex: "F97316")
    static let lockedGray = Color(hex: "4B5563")

    static var soloLevelingGradient: LinearGradient {
        LinearGradient(
            colors: [accentBlue, accentViolet],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var legendaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "9333EA"), Color(hex: "EC4899")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Wish Card

struct WishCard: View {
    let wish: WishResponse
    let userXp: Int
    let onTap: () -> Void

    private var isClaimable: Bool {
        wish.isClaimable(userXp: userXp)
    }

    private var cardOpacity: Double {
        switch wish.status {
        case .AVAILABLE: return isClaimable ? 1.0 : 0.7
        case .COOLDOWN: return 0.6
        case .LOCKED: return 0.5
        case .CLAIMED: return 0.8
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header: Rarity + Status
                HStack {
                    // Rarity badge
                    HStack(spacing: 4) {
                        Image(systemName: wish.rarity.icon)
                            .font(.caption2)
                        Text(wish.rarity.displayName)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(wish.rarity.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(wish.rarity.color.opacity(0.2))
                    .clipShape(Capsule())

                    Spacer()

                    // Status icon
                    statusBadge
                }

                // Title
                Text(wish.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                // Description (if available)
                if let description = wish.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Stats row
                HStack(spacing: 16) {
                    // XP Cost
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.yellow)
                        Text(wish.xpCostDisplay)
                            .foregroundStyle(isClaimable ? .white : .secondary)
                    }
                    .font(.caption.weight(.medium))

                    // Dopamine Potential
                    HStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(RewardColors.accentViolet)
                        Text(wish.dopaminePotentialDisplay)
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)

                    Spacer()

                    // Risk indicator
                    riskIndicator
                }

                // Cooldown timer (if applicable)
                if wish.status == .COOLDOWN, let hours = wish.cooldownRemainingHours {
                    cooldownBanner(hours: hours)
                }

                // Desensitization alert
                if wish.desensAlert {
                    desensAlertBanner
                }
            }
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(cardOverlay)
            .shadow(color: glowColor.opacity(0.3), radius: isClaimable ? 15 : 5, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .opacity(cardOpacity)
        .animation(.easeInOut(duration: 0.2), value: isClaimable)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch wish.status {
        case .AVAILABLE:
            if isClaimable {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "lock.open.fill")
                    .foregroundStyle(.secondary)
            }
        case .COOLDOWN:
            Image(systemName: "clock.fill")
                .foregroundStyle(RewardColors.cooldownOrange)
        case .LOCKED:
            Image(systemName: "lock.fill")
                .foregroundStyle(RewardColors.lockedGray)
        case .CLAIMED:
            Image(systemName: "gift.fill")
                .foregroundStyle(RewardColors.accentViolet)
        }
    }

    @ViewBuilder
    private var riskIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(riskColor(for: index))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private func riskColor(for index: Int) -> Color {
        let level: Int
        switch wish.volatilityRisk {
        case .LOW: level = 1
        case .MEDIUM: level = 2
        case .HIGH: level = 3
        }
        return index < level ? wish.volatilityRisk.color : Color.gray.opacity(0.3)
    }

    @ViewBuilder
    private func cooldownBanner(hours: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "hourglass")
            Text("\(hours)h remaining")
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(RewardColors.cooldownOrange)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(RewardColors.cooldownOrange.opacity(0.15))
        .clipShape(Capsule())
    }

    private var desensAlertBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("Desensitization warning")
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.red)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.red.opacity(0.15))
        .clipShape(Capsule())
    }

    private var cardBackground: some View {
        ZStack {
            // Base material
            Rectangle()
                .fill(.ultraThinMaterial)

            // Rarity tint
            Rectangle()
                .fill(wish.rarity.glowColor.opacity(0.1))

            // Claimable glow
            if isClaimable {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [RewardColors.accentBlue.opacity(0.1), RewardColors.accentViolet.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }

    private var cardOverlay: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: isClaimable
                        ? [RewardColors.accentBlue.opacity(0.5), RewardColors.accentViolet.opacity(0.3)]
                        : [.white.opacity(0.1), .white.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isClaimable ? 1.5 : 0.5
            )
    }

    private var glowColor: Color {
        if isClaimable {
            return wish.rarity == .LEGENDARY ? RewardColors.accentPurple : RewardColors.accentBlue
        }
        return .clear
    }
}

// MARK: - XP Mana Bar

struct XPManaBar: View {
    let currentXp: Int
    let xpToNextLevel: Int
    let level: Int
    let accentColor: Color

    private var progress: Double {
        guard xpToNextLevel > 0 else { return 0 }
        return min(Double(currentXp) / Double(xpToNextLevel), 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Level display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("LV.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Text("\(level)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(currentXp) / \(xpToNextLevel) XP")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(.white.opacity(0.1))

                    // Progress fill with glow
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [accentColor, accentColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .shadow(color: accentColor.opacity(0.6), radius: 8, x: 0, y: 0)

                    // Animated shimmer
                    if progress > 0 {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.3), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress)
                    }
                }
            }
            .frame(height: 14)
            .animation(.spring(response: 0.5), value: progress)
        }
        .padding(16)
        .glassEffect(material: .ultraThin, radius: 16)
    }
}

// MARK: - Motivation Phase Indicator

struct MotivationPhaseIndicator: View {
    let phase: Int
    let phaseDescription: String
    let circuitBreakerActive: Bool

    private var phaseColor: Color {
        switch phase {
        case 1...4: return .blue
        case 5, 6: return .green
        case 7: return .gray
        case 8...10: return .yellow
        case 11...13: return .red
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Phase number circle
            ZStack {
                Circle()
                    .fill(phaseColor.opacity(0.2))
                    .frame(width: 44, height: 44)

                Text("\(phase)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(phaseColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Motivation Phase")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(phaseDescription)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            if circuitBreakerActive {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.shield.fill")
                    Text("CB")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.2))
                .clipShape(Capsule())
            }
        }
        .padding(12)
        .glassEffect(material: .ultraThin, radius: 12)
    }
}

// MARK: - Reward Stats Summary

struct RewardStatsSummary: View {
    let availableCount: Int
    let cooldownCount: Int
    let claimableCount: Int
    let totalXp: Int

    var body: some View {
        HStack(spacing: 12) {
            RewardStatBadge(
                title: "Available",
                value: "\(availableCount)",
                icon: "gift.fill",
                color: .green
            )

            RewardStatBadge(
                title: "Claimable",
                value: "\(claimableCount)",
                icon: "checkmark.circle.fill",
                color: RewardColors.accentBlue
            )

            RewardStatBadge(
                title: "Cooldown",
                value: "\(cooldownCount)",
                icon: "clock.fill",
                color: RewardColors.cooldownOrange
            )
        }
    }
}

struct RewardStatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassEffect(material: .ultraThin, radius: 12)
    }
}

// MARK: - Empty Wishes Placeholder

struct EmptyWishesPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(RewardColors.accentViolet)

            Text("No Wishes Yet")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Create your first wish to start earning rewards for your progress!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .glassEffect(material: .ultraThin, radius: 20)
    }
}

// MARK: - Section Header

struct RewardSectionHeader: View {
    let title: String
    let icon: String?
    let count: Int?

    init(title: String, icon: String? = nil, count: Int? = nil) {
        self.title = title
        self.icon = icon
        self.count = count
    }

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundStyle(RewardColors.accentViolet)
            }
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)

            if let count = count {
                Text("(\(count))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Wish Card - Claimable") {
    ZStack {
        Color.black.ignoresSafeArea()

        WishCard(
            wish: WishResponse(
                wishId: "1",
                userId: "user",
                title: "1h Anime Marathon",
                description: "Watch Solo Leveling episodes",
                baseDopaminePotential: 75,
                rarity: .RARE,
                volatilityRisk: .MEDIUM,
                cooldownHours: 24,
                longtermImpact: 30,
                history: WishHistory(timesUsed: 5, avgSatisfaction: 8.5),
                lastUsed: nil,
                currentXpCost: 350,
                isActive: true,
                status: .AVAILABLE,
                createdAt: nil,
                updatedAt: nil,
                desensAlert: false,
                cooldownRemainingHours: nil
            ),
            userXp: 500,
            onTap: {}
        )
        .padding()
    }
}

#Preview("XP Mana Bar") {
    ZStack {
        Color.black.ignoresSafeArea()

        XPManaBar(
            currentXp: 750,
            xpToNextLevel: 1000,
            level: 42,
            accentColor: RewardColors.accentBlue
        )
        .padding()
    }
}
