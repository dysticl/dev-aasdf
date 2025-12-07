//
//  StatusWindowView.swift
//  dev-aasdf
//
//  Solo Leveling Status Window with Apple Liquid Glass Design
//  "I alone level up." - Sung Jin-Woo
//

import SwiftUI

struct StatusWindowView: View {
    @StateObject private var viewModel = LevelingViewModel()
    @State private var showDimensions = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xxl) {
                // Header with Hunter Info
                headerSection

                // Level & XP Progress
                levelSection

                // Score Cards
                scoreCardsSection

                // Dimension Progress (Expandable)
                dimensionSection

                // Stats Grid
                statsGridSection

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Color.shadowBackground)
        .task {
            await viewModel.loadAllData()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .overlay {
            if viewModel.showLevelUp, let event = viewModel.levelUpEvent {
                LevelUpOverlay(event: event) {
                    viewModel.dismissLevelUp()
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Rank Badge
            HStack {
                Image(systemName: viewModel.hunterRank.icon)
                    .font(.system(size: 24, weight: .bold))
                Text(viewModel.rankDisplay)
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(viewModel.hunterRank.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .glassEffect(material: .ultraThin, radius: 100)

            // Username
            Text(viewModel.username)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)

            // Total Score
            HStack(spacing: 4) {
                Text("Total Score:")
                    .foregroundStyle(.secondary)
                Text(String(format: "%.1f", viewModel.totalScore))
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
        .padding(.top, 40)
    }

    // MARK: - Level Section

    private var levelSection: some View {
        VStack(spacing: 16) {
            // Level Display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("LV.")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.secondary)
                Text("\(viewModel.level)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            // XP Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(.white.opacity(0.1))
                            .frame(height: 12)

                        // Progress
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        viewModel.hunterRank.color,
                                        viewModel.hunterRank.color.opacity(0.7),
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.xpProgress, height: 12)
                            .animation(.spring(response: 0.5), value: viewModel.xpProgress)
                    }
                }
                .frame(height: 12)

                // XP Text
                HStack {
                    Text("\(viewModel.xpCurrent) / \(viewModel.xpToNextLevel) XP")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.0f%%", viewModel.xpProgress * 100))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(viewModel.hunterRank.color)
                }
            }
        }
        .padding(20)
        .glassEffect(material: .ultraThin, radius: DesignSystem.CornerRadius.large)
    }

    // MARK: - Score Cards Section

    private var scoreCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCORES")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)

            HStack(spacing: 12) {
                ScoreCard(
                    title: "Best Self",
                    score: viewModel.bestSelfScore,
                    icon: "star.fill",
                    color: .yellow
                )

                ScoreCard(
                    title: "Discipline",
                    score: viewModel.disciplineScore,
                    icon: "flame.fill",
                    color: .orange
                )

                ScoreCard(
                    title: "Execution",
                    score: viewModel.executionScore,
                    icon: "checkmark.seal.fill",
                    color: .green
                )
            }
        }
    }

    // MARK: - Dimension Section

    private var dimensionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showDimensions.toggle()
                }
            } label: {
                HStack {
                    Text("DIMENSIONS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1.5)
                    Spacer()
                    Image(systemName: showDimensions ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if showDimensions {
                VStack(spacing: 8) {
                    ForEach(viewModel.dimensions) { dimension in
                        DimensionProgressRow(dimension: dimension)
                    }
                }
                .padding(16)
                .glassEffect(material: .ultraThin, radius: DesignSystem.CornerRadius.medium)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Stats Grid Section

    private var statsGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STATS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    title: "Current Streak",
                    value: "\(viewModel.currentStreak)",
                    icon: "flame.fill",
                    color: .red
                )

                StatCard(
                    title: "Longest Streak",
                    value: "\(viewModel.longestStreak)",
                    icon: "trophy.fill",
                    color: .yellow
                )

                StatCard(
                    title: "Tasks Done",
                    value: "\(viewModel.userStats?.totalTasksCompleted ?? 0)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "Artifacts",
                    value: "\(viewModel.userStats?.totalArtifactsCompleted ?? 0)",
                    icon: "sparkles",
                    color: .purple
                )
            }
        }
    }
}

// MARK: - Score Card Component

struct ScoreCard: View {
    let title: String
    let score: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(String(format: "%.0f", score))
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassEffect(material: .ultraThin, radius: DesignSystem.CornerRadius.medium)
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .glassEffect(material: .ultraThin, radius: DesignSystem.CornerRadius.medium)
    }
}

// MARK: - Dimension Progress Row

struct DimensionProgressRow: View {
    let dimension: UserDimensionProgress

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: dimension.icon)
                    .font(.caption)
                    .foregroundStyle(dimension.color)
                Text(dimension.name)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                Spacer()
                Text(String(format: "%.0f%%", dimension.progressPercent))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(dimension.color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.1))
                        .frame(height: 6)

                    Capsule()
                        .fill(dimension.color)
                        .frame(width: geometry.size.width * dimension.progressRatio, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Level Up Overlay

struct LevelUpOverlay: View {
    let event: LevelUpEvent
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Content
            VStack(spacing: 24) {
                // Icon
                if event.rankChanged {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(event.newRank?.color ?? .yellow)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                }

                // Title
                Text(event.rankChanged ? "RANK UP!" : "LEVEL UP!")
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(.white)

                // Level Display
                HStack(spacing: 8) {
                    Text("LV. \(event.oldLevel)")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.yellow)
                    Text("LV. \(event.newLevel)")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                }

                // Rank Change (if applicable)
                if event.rankChanged, let newRank = event.newRank {
                    Text(newRank.rawValue)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(newRank.color)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(newRank.color.opacity(0.2))
                        .clipShape(Capsule())
                }

                // Message
                Text(event.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // XP Awarded
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.yellow)
                    Text("+\(event.xpAwarded) XP")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .padding(32)
            .glassEffect(material: .regular, radius: 32)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StatusWindowView()
        .preferredColorScheme(.dark)
}
