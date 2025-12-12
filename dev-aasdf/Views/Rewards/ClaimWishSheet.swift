//
//  ClaimWishSheet.swift
//  dev-aasdf
//
//  Claim Sheet for Adaptive Reward System
//  Solo Leveling + Liquid Glass Design
//

import SwiftUI

struct ClaimWishSheet: View {
    let wish: WishResponse
    let userXp: Int
    let onClaim: (Double) -> Void
    let onCancel: () -> Void
    @Binding var isClaiming: Bool

    @State private var satisfactionScore: Double = 7.0
    @State private var animateGlow = false

    private var xpCost: Int {
        wish.currentXpCost ?? 0
    }

    private var xpAfterClaim: Int {
        max(0, userXp - xpCost)
    }

    private var canAfford: Bool {
        userXp >= xpCost
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(.white.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 24) {
                    // Wish header with glow
                    wishHeader

                    // XP Cost breakdown
                    xpCostSection

                    // Satisfaction slider
                    satisfactionSection

                    // Info cards
                    infoCardsSection

                    // Action buttons
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(sheetBackground)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
        }
    }

    // MARK: - Wish Header

    private var wishHeader: some View {
        VStack(spacing: 16) {
            // Rarity glow circle
            ZStack {
                // Outer glow
                Circle()
                    .fill(wish.rarity.glowColor)
                    .frame(width: 100, height: 100)
                    .blur(radius: animateGlow ? 30 : 20)
                    .scaleEffect(animateGlow ? 1.2 : 1.0)

                // Icon circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [wish.rarity.color, wish.rarity.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                // Icon
                Image(systemName: "gift.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }

            // Title
            Text(wish.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            // Rarity badge
            HStack(spacing: 6) {
                Image(systemName: wish.rarity.icon)
                Text(wish.rarity.displayName)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(wish.rarity.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(wish.rarity.color.opacity(0.2))
            .clipShape(Capsule())

            // Description
            if let description = wish.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - XP Cost Section

    private var xpCostSection: some View {
        VStack(spacing: 12) {
            Text("XP COST")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)

            HStack(spacing: 20) {
                // Current XP
                VStack(spacing: 4) {
                    Text("Current")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(userXp)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }

                // Arrow
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundStyle(.yellow)

                // Cost
                VStack(spacing: 4) {
                    Text("Cost")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("-\(xpCost)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.red)
                }

                // Arrow
                Image(systemName: "arrow.right")
                    .font(.title3)
                    .foregroundStyle(.yellow)

                // After
                VStack(spacing: 4) {
                    Text("After")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(xpAfterClaim)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(canAfford ? .green : .red)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .glassEffect(material: .ultraThin, radius: 16)
        }
    }

    // MARK: - Satisfaction Section

    private var satisfactionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("EXPECTED SATISFACTION")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
                Spacer()
                Text(String(format: "%.1f", satisfactionScore))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(satisfactionColor)
            }

            // Custom slider
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track background
                        Capsule()
                            .fill(.white.opacity(0.1))

                        // Filled track
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.red, .yellow, .green],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (satisfactionScore / 10))

                        // Thumb
                        Circle()
                            .fill(.white)
                            .frame(width: 24, height: 24)
                            .shadow(color: satisfactionColor.opacity(0.5), radius: 8)
                            .offset(x: (geometry.size.width - 24) * (satisfactionScore / 10))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let newValue = value.location.x / geometry.size.width * 10
                                        satisfactionScore = max(0, min(10, newValue))
                                    }
                            )
                    }
                }
                .frame(height: 24)

                // Labels
                HStack {
                    Text("0")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("5")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("10")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .glassEffect(material: .ultraThin, radius: 16)

            // Hint text
            Text("Rate how satisfying you expect this reward to be")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var satisfactionColor: Color {
        switch satisfactionScore {
        case 0..<3: return .red
        case 3..<6: return .yellow
        case 6..<8: return .green
        default: return .cyan
        }
    }

    // MARK: - Info Cards

    private var infoCardsSection: some View {
        HStack(spacing: 12) {
            InfoCard(
                title: "Dopamine",
                value: "\(wish.baseDopaminePotential)%",
                icon: "brain.head.profile",
                color: RewardColors.accentViolet
            )

            InfoCard(
                title: "Cooldown",
                value: "\(wish.cooldownHours)h",
                icon: "clock.fill",
                color: RewardColors.cooldownOrange
            )

            InfoCard(
                title: "Risk",
                value: wish.volatilityRisk.displayName.replacingOccurrences(of: " Risk", with: ""),
                icon: "exclamationmark.triangle.fill",
                color: wish.volatilityRisk.color
            )
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Claim button
            Button {
                onClaim(satisfactionScore)
            } label: {
                HStack(spacing: 8) {
                    if isClaiming {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "gift.fill")
                    }
                    Text(isClaiming ? "Claiming..." : "Claim Reward")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    canAfford
                        ? RewardColors.soloLevelingGradient
                        : LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: canAfford ? RewardColors.glowViolet : .clear, radius: 10, x: 0, y: 5)
            }
            .disabled(!canAfford || isClaiming)

            // Cancel button
            Button {
                onCancel()
            } label: {
                Text("Cancel")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.secondary)
            }
            .disabled(isClaiming)

            // Warning if can't afford
            if !canAfford {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text("Not enough XP to claim this reward")
                }
                .font(.caption)
                .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Background

    private var sheetBackground: some View {
        ZStack {
            Color.black

            // Gradient glow based on rarity
            RadialGradient(
                colors: [wish.rarity.glowColor.opacity(0.3), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Info Card

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassEffect(material: .ultraThin, radius: 12)
    }
}

// MARK: - Preview

#Preview {
    ClaimWishSheet(
        wish: WishResponse(
            wishId: "1",
            userId: "user",
            title: "1h Anime Marathon",
            description: "Watch Solo Leveling episodes and enjoy some relaxation time",
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
        onClaim: { _ in },
        onCancel: {},
        isClaiming: .constant(false)
    )
}
