//
//  HomeView.swift
//  dev-aasdf
//  REDESIGNED mit Solo Leveling Theme - Funktionalität INTAKT
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ArtifactsViewModel()
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
            VStack(alignment: .leading, spacing: 4) {
                Text("Willkommen, Hunter")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.shadowText)

                Text("Du hast \(viewModel.pendingCount) offene Aufgaben")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.shadowTextSecondary)
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

    // MARK: - Stats Overview

    private var statsOverview: some View {
        HStack(spacing: 12) {
            StatMiniCard(title: "XP HEUTE", value: "+0", icon: "sparkles", color: SoloColors.xpGold)
            StatMiniCard(
                title: "STREAK", value: "0", icon: "flame.fill", color: SoloColors.successGreen)
            StatMiniCard(
                title: "LEVEL", value: "1", icon: "star.fill", color: SoloColors.neonViolet)
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
