//
//  RewardDashboardSection.swift
//  dev-aasdf
//
//  Reward Dashboard Section for Status Window
//  Solo Leveling + Liquid Glass Design
//

import SwiftUI

/// Reward section to be embedded in StatusWindowView
struct RewardDashboardSection: View {
    @ObservedObject var viewModel: RewardViewModel
    @State private var showAddWishSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                RewardSectionHeader(
                    title: "WISH POOL",
                    icon: "sparkles",
                    count: viewModel.totalWishCount
                )

                Spacer()

                // Add wish button
                Button {
                    showAddWishSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(RewardColors.accentViolet)
                }
            }

            // Motivation phase indicator
            if let profile = viewModel.userProfile {
                MotivationPhaseIndicator(
                    phase: profile.motivation.motivationPhase,
                    phaseDescription: profile.motivation.phaseDescription,
                    circuitBreakerActive: profile.motivation.circuitBreakerActive
                )
            }

            // Stats summary
            RewardStatsSummary(
                availableCount: viewModel.availableWishes.count,
                cooldownCount: viewModel.cooldownWishes.count,
                claimableCount: viewModel.claimableWishes.count,
                totalXp: viewModel.currentXp
            )

            // Wishes list
            if viewModel.wishes.isEmpty {
                EmptyWishesPlaceholder()
            } else {
                wishesSection
            }
        }
        .sheet(isPresented: $viewModel.showClaimSheet) {
            if let wish = viewModel.selectedWish {
                ClaimWishSheet(
                    wish: wish,
                    userXp: viewModel.currentXp,
                    onClaim: { satisfaction in
                        Task {
                            await viewModel.claimWish(satisfactionScore: satisfaction)
                        }
                    },
                    onCancel: {
                        viewModel.cancelClaim()
                    },
                    isClaiming: $viewModel.isClaimingWish
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showAddWishSheet) {
            AddWishSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Wishes Section

    @ViewBuilder
    private var wishesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Claimable wishes (highlighted)
            if !viewModel.claimableWishes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("READY TO CLAIM")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.green)
                        .tracking(1)

                    ForEach(viewModel.claimableWishes) { wish in
                        WishCard(
                            wish: wish,
                            userXp: viewModel.currentXp,
                            onTap: { viewModel.selectWishForClaim(wish) }
                        )
                    }
                }
            }

            // Other available wishes
            let nonClaimableAvailable = viewModel.availableWishes.filter { wish in
                !viewModel.claimableWishes.contains(where: { c in c.wishId == wish.wishId })
            }
            if !nonClaimableAvailable.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AVAILABLE")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1)

                    ForEach(nonClaimableAvailable) { wish in
                        WishCard(
                            wish: wish,
                            userXp: viewModel.currentXp,
                            onTap: { viewModel.selectWishForClaim(wish) }
                        )
                    }
                }
            }

            // Cooldown wishes (collapsible)
            if !viewModel.cooldownWishes.isEmpty {
                DisclosureGroup {
                    ForEach(viewModel.cooldownWishes) { wish in
                        WishCard(
                            wish: wish,
                            userXp: viewModel.currentXp,
                            onTap: {}
                        )
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(RewardColors.cooldownOrange)
                        Text("On Cooldown (\(viewModel.cooldownWishes.count))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.secondary)
            }
        }
    }
}

// MARK: - Add Wish Sheet

struct AddWishSheet: View {
    @ObservedObject var viewModel: RewardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var dopaminePotential: Double = 50
    @State private var selectedRarity: WishRarity = .COMMON
    @State private var selectedRisk: VolatilityRisk = .LOW
    @State private var cooldownHours: Double = 24
    @State private var longtermImpact: Double = 50
    @State private var isCreating = false

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextField("e.g., 1h Gaming Session", text: $title)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .glassEffect(material: .ultraThin, radius: 12)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextField("What does this reward involve?", text: $description, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(2...4)
                            .padding(12)
                            .glassEffect(material: .ultraThin, radius: 12)
                    }

                    // Rarity picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rarity")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            ForEach(WishRarity.allCases, id: \.self) { rarity in
                                Button {
                                    selectedRarity = rarity
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: rarity.icon)
                                        Text(rarity.displayName)
                                    }
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(selectedRarity == rarity ? .white : rarity.color)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedRarity == rarity
                                            ? rarity.color
                                            : rarity.color.opacity(0.2)
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // Risk picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Volatility Risk")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            ForEach(VolatilityRisk.allCases, id: \.self) { risk in
                                Button {
                                    selectedRisk = risk
                                } label: {
                                    Text(risk.displayName)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(selectedRisk == risk ? .white : risk.color)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedRisk == risk
                                                ? risk.color
                                                : risk.color.opacity(0.2)
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // Dopamine Potential slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Dopamine Potential")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(dopaminePotential))%")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(RewardColors.accentViolet)
                        }
                        Slider(value: $dopaminePotential, in: 0...100, step: 5)
                            .tint(RewardColors.accentViolet)
                    }
                    .padding(12)
                    .glassEffect(material: .ultraThin, radius: 12)

                    // Cooldown slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Cooldown Period")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(cooldownHours))h")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(RewardColors.cooldownOrange)
                        }
                        Slider(value: $cooldownHours, in: 1...168, step: 1)
                            .tint(RewardColors.cooldownOrange)
                    }
                    .padding(12)
                    .glassEffect(material: .ultraThin, radius: 12)

                    // Long-term Impact slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Long-term Impact")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(longtermImpact))")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.green)
                        }
                        Slider(value: $longtermImpact, in: 0...100, step: 5)
                            .tint(.green)
                    }
                    .padding(12)
                    .glassEffect(material: .ultraThin, radius: 12)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("New Wish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        createWish()
                    } label: {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text("Create")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isValid || isCreating)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func createWish() {
        isCreating = true
        Task {
            await viewModel.createWish(
                title: title.trimmingCharacters(in: .whitespaces),
                description: description.isEmpty ? nil : description,
                dopaminePotential: Int(dopaminePotential),
                rarity: selectedRarity,
                volatilityRisk: selectedRisk,
                cooldownHours: Int(cooldownHours),
                longtermImpact: Int(longtermImpact)
            )
            isCreating = false
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            RewardDashboardSection(viewModel: .preview)
                .padding()
        }
    }
    .preferredColorScheme(.dark)
}
