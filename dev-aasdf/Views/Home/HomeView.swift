//
//  HomeView.swift
//  dev-aasdf
//  REDESIGNED mit Solo Leveling Theme - Funktionalität INTAKT
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ArtifactsViewModel()
    @StateObject private var levelingVM = LevelingViewModel()
    @State private var selectedTab = 0
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // NEW: Shadow Background statt AmbientGlowBackground
                Color.shadowBackground
                    .ignoresSafeArea()

                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        statsOverview
                        statusTabs
                        artifactsListSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .refreshable {
                    await viewModel.fetchArtifacts()
                    await levelingVM.loadUserStats()
                    await levelingVM.loadCurrentDaystrike()
                }

                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            showCreateSheet = true
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.fetchCategories()
            await viewModel.fetchArtifacts()
            await levelingVM.loadUserStats()
            await levelingVM.loadCurrentDaystrike()
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
        HStack(alignment: .top) {  // Align top for better layout with countdown
            VStack(alignment: .leading, spacing: 4) {
                Text("Willkommen, Hunter")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.shadowText)

                Text("Du hast \(viewModel.pendingCount) offene Aufgaben")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.shadowTextSecondary)

                // GLOBAL COUNTDOWN
                if let nearest = nearestInProgressArtifact,
                    let deadline = nearest.deadline?.toISO8601Date()
                {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(SoloColors.dangerRed)
                            .font(.system(size: 12))

                        Text("Deadline: \(nearest.taskName)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(SoloColors.textPrimary)
                            .lineLimit(1)

                        CountdownTimerView(
                            deadline: deadline, fontSize: .system(size: 12), showIcon: false)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        Capsule()
                            .fill(SoloColors.cardBackground.opacity(0.8))
                            .overlay(
                                Capsule().stroke(SoloColors.dangerRed.opacity(0.3), lineWidth: 1))
                    )
                    .padding(.top, 4)
                }
            }

            Spacer()

            NavigationLink(destination: ProfileView()) {
                Circle()
                    .fill(Color.violetGlow.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.violetGlow)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.violetGlow.opacity(0.3), lineWidth: 1.5)
                    )
            }
        }
    }

    private var nearestInProgressArtifact: Artifact? {
        viewModel.artifacts
            .filter { $0.status == "in_progress" }
            .compactMap { artifact -> (Artifact, Date)? in
                guard let deadlineStr = artifact.deadline,
                    let date = deadlineStr.toISO8601Date()
                else { return nil }
                return (artifact, date)
            }
            .sorted { $0.1 < $1.1 }
            .first?.0
    }

    // MARK: - Stats Overview

    private var statsOverview: some View {
        HStack(spacing: 12) {
            StatMiniCard(title: "XP HEUTE", value: "+0", icon: "sparkles", color: SoloColors.xpGold)
            StatMiniCard(
                title: "STREAK",
                value: "\(levelingVM.currentStreak)",
                icon: "flame.fill",
                color: SoloColors.successGreen
            )
            StatMiniCard(
                title: "LEVEL", value: "\(levelingVM.level)", icon: "star.fill",
                color: SoloColors.neonViolet)
        }
    }

    // MARK: - Status Tabs

    private var statusTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatusTabButton(title: "Alle", isSelected: selectedTab == 0) {
                    selectedTab = 0
                    viewModel.selectedStatus = nil
                    Task { await viewModel.fetchArtifacts() }
                }

                StatusTabButton(title: "Pending", isSelected: selectedTab == 1) {
                    selectedTab = 1
                    viewModel.selectedStatus = "pending"
                    Task { await viewModel.fetchArtifacts() }
                }

                StatusTabButton(title: "In Progress", isSelected: selectedTab == 2) {
                    selectedTab = 2
                    viewModel.selectedStatus = "in_progress"
                    Task { await viewModel.fetchArtifacts() }
                }

                StatusTabButton(title: "Completed", isSelected: selectedTab == 3) {
                    selectedTab = 3
                    viewModel.selectedStatus = "completed"
                    Task { await viewModel.fetchArtifacts() }
                }
            }
        }
    }

    // MARK: - Artifacts List

    private var artifactsListSection: some View {
        LazyVStack(spacing: 12) {
            if viewModel.isLoading && viewModel.artifacts.isEmpty {
                ProgressView()
                    .tint(.white)
                    .padding(.top, 40)
            } else if viewModel.artifacts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.3))
                    Text("Keine Aufgaben")
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 40)
            } else {
                ForEach(viewModel.artifacts) { artifact in
                    NavigationLink(
                        destination: ArtifactDetailView(
                            artifactId: artifact.id, viewModel: viewModel)
                    ) {
                        LiquidGlassArtifactCard(artifact: artifact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

}

// MARK: - Liquid Glass Artifact Card

struct LiquidGlassArtifactCard: View {
    let artifact: Artifact

    var statusColor: Color {
        switch artifact.status {
        case "pending": return .gray
        case "in_progress": return .blue
        case "awaiting_proof": return .orange
        case "completed": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Image(systemName: artifact.status == "completed" ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundStyle(
                    artifact.status == "completed"
                        ? LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [.gray.opacity(0.4), .gray.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )

            // Task Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(artifact.taskName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Spacer()

                    if let priority = artifact.priority,
                        priority.lowercased() == "high" || priority.lowercased() == "critical"
                    {
                        PriorityBadge(priority: priority)
                    }
                }

                HStack(spacing: 8) {
                    Text(artifact.categoryIcon ?? "📋")
                        .font(.system(size: 14))

                    Text(artifact.category)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    Text("•")
                        .foregroundColor(.white.opacity(0.4))

                    if let xp = artifact.aiEstimate?.estimatedXp {
                        Text("\(xp) XP")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(LiquidGlassGradients.xpGold)
                    }
                }

                // IN PROGRESS COUNTDOWN
                if artifact.status == "in_progress", let deadlineStr = artifact.deadline,
                    let deadline = deadlineStr.toISO8601Date()
                {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 12))
                            .foregroundColor(SoloColors.neonBlue)

                        CountdownTimerView(
                            deadline: deadline, fontSize: .caption, showIcon: false, isCompact: true
                        )
                    }
                    .padding(.top, 2)
                } else if artifact.status == "pending", artifact.deadline == nil {
                    // Optional: Show "No Deadline" if desired, but countdown is priority
                }
            }
        }
        .padding(16)
        .liquidGlassCard(statusColor: statusColor)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .appChrome()
        .appBackground()
}
