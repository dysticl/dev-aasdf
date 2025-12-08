//
//  ModernTabBar.swift
//  dev-aasdf
//
//  iOS 26 Liquid Glass Tab Bar with Solo Leveling HUD Design
//

import SwiftUI

struct TabItem: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
}

// MARK: - Modern Tab Bar (iOS 26 Style)

struct ModernTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]

    @Namespace private var animation

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxl) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                TabBarButton(
                    icon: tab.icon,
                    label: tab.label,
                    isSelected: selectedTab == index,
                    namespace: animation
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xxl)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            Capsule()
                .fill(Color.clear)
                .glassEffect(.regular.interactive(), in: .capsule)
        )
        .shadow(color: AppTheme.accent.opacity(0.2), radius: 20, y: 8)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    var namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.clear)
                            .glassEffect(.regular.tint(AppTheme.accent).interactive(), in: .circle)
                            .frame(width: 44, height: 44)
                            .shadow(color: AppTheme.accent.opacity(0.6), radius: 12)
                            .matchedGeometryEffect(id: "selectedTab", in: namespace)
                    }

                    Image(systemName: icon)
                        .font(.system(size: isSelected ? 20 : 22, weight: .medium))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                        .frame(width: 44, height: 44)
                }

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : .clear)
                    .opacity(isSelected ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Main Tab Container

struct MainTabContainer: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authViewModel: AuthViewModel

    private let tabs = [
        TabItem(icon: "house.fill", label: "Home"),
        TabItem(icon: "person.fill", label: "Profile"),
    ]

    var body: some View {
        ZStack {
            // Background - Single unified background
            AppTheme.background.ignoresSafeArea()

            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    HomeContentView()
                case 1:
                    ProfileView()
                default:
                    HomeContentView()
                }
            }
            .transition(.opacity)

            // Tab Bar Overlay
            VStack {
                Spacer()
                ModernTabBar(selectedTab: $selectedTab, tabs: tabs)
                    .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
        .ignoresSafeArea(.keyboard)
        .appChrome()
    }
}

// MARK: - Home Content View

struct HomeContentView: View {
    @StateObject private var viewModel = ArtifactsViewModel()
    @State private var selectedStatusTab = 0
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Main Content - NO duplicate background here
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xxl) {
                        headerSection
                        statsOverview
                        statusTabs
                        artifactsListSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.xl)
                    .padding(.bottom, 140)
                }
                .refreshable {
                    await viewModel.fetchArtifacts()
                }

                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            showCreateSheet = true
                        }
                        .padding(.trailing, DesignSystem.Spacing.xl)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.fetchCategories()
            await viewModel.fetchArtifacts()
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateArtifactView(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("WILLKOMMEN, HUNTER")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.accent.opacity(0.8))
                    .tracking(3)

                Text("Quest Dashboard")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .soloGlow(color: AppTheme.accent, radius: 10)

                Text("\(viewModel.pendingCount) offene Quests")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Profile Avatar with HUD style
            Circle()
                .fill(Color.clear)
                .glassEffect(.regular, in: .circle)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.7))
                )
                .overlay(
                    Circle()
                        .stroke(AppTheme.accent.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: AppTheme.accent.opacity(0.4), radius: 10)
        }
    }

    // MARK: - Stats Overview (HUD Style)

    private var statsOverview: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            HUDStatCard(title: "XP", value: "+0", icon: "sparkles", color: AppTheme.xpGold)
            HUDStatCard(title: "STREAK", value: "0", icon: "flame.fill", color: AppTheme.success)
            HUDStatCard(
                title: "LVL", value: "1", icon: "star.fill", color: AppTheme.accentSecondary)
        }
    }

    // MARK: - Status Tabs

    private var statusTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.md) {
                HUDTabButton(title: "ALLE", isSelected: selectedStatusTab == 0) {
                    selectedStatusTab = 0
                    viewModel.selectedStatus = nil
                    Task { await viewModel.fetchArtifacts() }
                }

                HUDTabButton(title: "PENDING", isSelected: selectedStatusTab == 1) {
                    selectedStatusTab = 1
                    viewModel.selectedStatus = "pending"
                    Task { await viewModel.fetchArtifacts() }
                }

                HUDTabButton(title: "ACTIVE", isSelected: selectedStatusTab == 2) {
                    selectedStatusTab = 2
                    viewModel.selectedStatus = "in_progress"
                    Task { await viewModel.fetchArtifacts() }
                }

                HUDTabButton(title: "DONE", isSelected: selectedStatusTab == 3) {
                    selectedStatusTab = 3
                    viewModel.selectedStatus = "completed"
                    Task { await viewModel.fetchArtifacts() }
                }
            }
        }
    }

    // MARK: - Artifacts List

    private var artifactsListSection: some View {
        LazyVStack(spacing: DesignSystem.Spacing.md) {
            if viewModel.isLoading && viewModel.artifacts.isEmpty {
                ProgressView()
                    .tint(AppTheme.accent)
                    .padding(.top, 60)
            } else if viewModel.artifacts.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.artifacts) { artifact in
                    NavigationLink(
                        destination: ArtifactDetailView(
                            artifactId: artifact.id, viewModel: viewModel)
                    ) {
                        QuestCard(artifact: artifact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "scroll")
                .font(.system(size: 56))
                .foregroundColor(AppTheme.accent.opacity(0.4))
                .soloGlow(color: AppTheme.accent, radius: 15)

            Text("KEINE QUESTS")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .tracking(2)

            Text("Erstelle deine erste Quest!")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.top, 60)
    }
}

// MARK: - HUD Stat Card

struct HUDStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .soloGlow(color: color, radius: 6)

            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: color.opacity(0.5), radius: 4)

            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(AppTheme.cardBackground.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.2), radius: 8)
    }
}

// MARK: - HUD Tab Button

struct HUDTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .tracking(1)
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.accent.opacity(0.25) : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? AppTheme.accent.opacity(0.6) : Color.white.opacity(0.15),
                            lineWidth: 1
                        )
                )
                .shadow(color: isSelected ? AppTheme.accent.opacity(0.3) : .clear, radius: 8)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Quest Card (Solo Leveling Style)

struct QuestCard: View {
    let artifact: Artifact

    var statusColor: Color {
        switch artifact.status {
        case "pending": return .gray
        case "in_progress": return AppTheme.accent
        case "awaiting_proof": return AppTheme.warning
        case "completed": return AppTheme.success
        case "cancelled": return AppTheme.error
        default: return .gray
        }
    }

    var statusIcon: String {
        switch artifact.status {
        case "completed": return "checkmark.circle.fill"
        case "in_progress": return "play.circle.fill"
        case "awaiting_proof": return "clock.fill"
        default: return "circle"
        }
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Status Icon
            Image(systemName: statusIcon)
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [statusColor, statusColor.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: statusColor.opacity(0.5), radius: 6)
                .frame(width: 32)

            // Quest Info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(artifact.taskName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Spacer()

                    if let priority = artifact.priority,
                        priority.lowercased() == "high" || priority.lowercased() == "critical"
                    {
                        Text(priority.uppercased())
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(AppTheme.error)
                            )
                            .shadow(color: AppTheme.error.opacity(0.4), radius: 4)
                    }
                }

                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(artifact.categoryIcon ?? "📋")
                        .font(.system(size: 12))

                    Text(artifact.category.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1)

                    if let xp = artifact.aiEstimate?.estimatedXp {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                            Text("+\(xp) XP")
                                .font(.system(size: 11, weight: .black))
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.xpGold, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppTheme.xpGold.opacity(0.4), radius: 4)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(AppTheme.cardBackground.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(statusColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: statusColor.opacity(0.15), radius: 10, y: 4)
    }
}

// MARK: - Backward Compatibility Aliases

typealias SoloArtifactCard = QuestCard
typealias StatusTabButton = HUDTabButton
typealias StatMiniCard = HUDStatCard

#Preview {
    MainTabContainer()
        .environmentObject(AuthViewModel())
}
