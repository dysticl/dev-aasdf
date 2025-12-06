//
//  ModernTabBar.swift
//  dev-aasdf
//
//  iOS 18 Clock-app style pill tab bar with Liquid Glass design
//

import SwiftUI

struct TabItem: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
}

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
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xxl)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
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
                    // Selected indicator background
                    if isSelected {
                        Circle()
                            .fill(LiquidGlassGradients.primary)
                            .frame(width: 44, height: 44)
                            .shadow(color: SoloColors.electricBlue.opacity(0.5), radius: 10)
                            .matchedGeometryEffect(id: "selectedTab", in: namespace)
                    }

                    Image(systemName: icon)
                        .font(.system(size: isSelected ? 20 : 22, weight: .medium))
                        .foregroundColor(isSelected ? .white : SoloColors.textSecondary)
                        .frame(width: 44, height: 44)
                }

                // Label (only visible when selected)
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
    }
}

// MARK: - Home Content View (without bottom bar)

struct HomeContentView: View {
    @StateObject private var viewModel = ArtifactsViewModel()
    @State private var selectedStatusTab = 0
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AmbientGlowBackground()

                // Main Content
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xxl) {
                        headerSection
                        statsOverview
                        statusTabs
                        artifactsListSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.xl)
                    .padding(.bottom, 140)  // Space for tab bar
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
                        .padding(.bottom, 120)  // Above tab bar
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
                Text("Willkommen, Hunter")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .glowEffect(color: SoloColors.electricBlue, radius: 15)

                Text("Du hast \(viewModel.pendingCount) offene Aufgaben")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SoloColors.textSecondary)
            }

            Spacer()

            // Profile Avatar
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundColor(SoloColors.textSecondary)
                )
                .overlay(
                    Circle()
                        .stroke(
                            LiquidGlassGradients.primary,
                            lineWidth: 2
                        )
                )
                .shadow(color: SoloColors.electricBlue.opacity(0.3), radius: 10)
        }
    }

    // MARK: - Stats Overview

    private var statsOverview: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            StatMiniCard(title: "XP Heute", value: "+0", color: SoloColors.xpGold, icon: "sparkles")
            StatMiniCard(
                title: "Streak", value: "0", color: SoloColors.successGreen, icon: "flame.fill")
            StatMiniCard(
                title: "Level", value: "1", color: SoloColors.hunterPurple, icon: "star.fill")
        }
    }

    // MARK: - Status Tabs

    private var statusTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.md) {
                StatusTabButton(title: "Alle", isSelected: selectedStatusTab == 0) {
                    selectedStatusTab = 0
                    viewModel.selectedStatus = nil
                    Task { await viewModel.fetchArtifacts() }
                }

                StatusTabButton(title: "Pending", isSelected: selectedStatusTab == 1) {
                    selectedStatusTab = 1
                    viewModel.selectedStatus = "pending"
                    Task { await viewModel.fetchArtifacts() }
                }

                StatusTabButton(title: "In Progress", isSelected: selectedStatusTab == 2) {
                    selectedStatusTab = 2
                    viewModel.selectedStatus = "in_progress"
                    Task { await viewModel.fetchArtifacts() }
                }

                StatusTabButton(title: "Completed", isSelected: selectedStatusTab == 3) {
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
                    .tint(.white)
                    .padding(.top, 60)
            } else if viewModel.artifacts.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.artifacts) { artifact in
                    NavigationLink(
                        destination: ArtifactDetailView(
                            artifactId: artifact.id, viewModel: viewModel)
                    ) {
                        SoloArtifactCard(artifact: artifact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "tray")
                .font(.system(size: 56))
                .foregroundColor(SoloColors.textTertiary)

            Text("Keine Aufgaben")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(SoloColors.textSecondary)

            Text("Erstelle deine erste Quest!")
                .font(.system(size: 14))
                .foregroundColor(SoloColors.textTertiary)
        }
        .padding(.top, 60)
    }
}

// MARK: - Solo Artifact Card

struct SoloArtifactCard: View {
    let artifact: Artifact

    var statusColor: Color {
        switch artifact.status {
        case "pending": return .gray
        case "in_progress": return SoloColors.electricBlue
        case "awaiting_proof": return SoloColors.warningOrange
        case "completed": return SoloColors.successGreen
        case "cancelled": return SoloColors.dangerRed
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Checkbox
            ZStack {
                Circle()
                    .stroke(statusColor.opacity(0.3), lineWidth: 2)
                    .frame(width: 28, height: 28)

                if artifact.status == "completed" {
                    Circle()
                        .fill(LiquidGlassGradients.success)
                        .frame(width: 28, height: 28)

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: statusColor.opacity(0.3), radius: 5)

            // Task Info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text(artifact.taskName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Spacer()

                    if let priority = artifact.priority,
                        priority.lowercased() == "high" || priority.lowercased() == "critical"
                    {
                        PriorityBadge(priority: priority)
                    }
                }

                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(artifact.categoryIcon ?? "📋")
                        .font(.system(size: 14))

                    Text(artifact.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(SoloColors.textTertiary)

                    Text("•")
                        .foregroundColor(SoloColors.textTertiary)

                    if let xp = artifact.aiEstimate?.estimatedXp {
                        HStack(spacing: 2) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                            Text("\(xp) XP")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(LiquidGlassGradients.xpGold)
                    }
                }
            }
        }
        .liquidGlassCard(statusColor: statusColor, padding: DesignSystem.Spacing.lg)
    }
}

#Preview {
    MainTabContainer()
        .environmentObject(AuthViewModel())
}
