//
//  HomeView.swift
//  dev-aasdf
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
                // Background Gradient
                LiquidGlassGradients.background
                    .ignoresSafeArea()

                // Ambient Glow Effects
                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .blur(radius: 120)
                    .offset(x: -100, y: -200)

                Circle()
                    .fill(Color.purple.opacity(0.06))
                    .blur(radius: 100)
                    .offset(x: 150, y: 300)

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
                    .padding(.bottom, 120)
                }
                .refreshable {
                    await viewModel.fetchArtifacts()
                }

                // Bottom Navigation Bar
                VStack {
                    Spacer()
                    bottomNavBar
                }
                .ignoresSafeArea(.keyboard)

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
                    .foregroundColor(.white)

                Text("Du hast \(viewModel.pendingCount) offene Aufgaben")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            NavigationLink(destination: ProfileView()) {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Stats Overview

    private var statsOverview: some View {
        HStack(spacing: 12) {
            StatMiniCard(title: "XP Heute", value: "+0", color: .orange)
            StatMiniCard(title: "Streak", value: "0 Tage", color: .green)
            StatMiniCard(title: "Level", value: "1", color: .purple)
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

    // MARK: - Bottom Navigation Bar

    private var bottomNavBar: some View {
        HStack {
            NavigationLink(destination: ProfileView()) {
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                    Text("Profile")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Material.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .frame(height: 80)
        .background(
            Rectangle()
                .fill(Material.ultraThinMaterial)
                .mask(
                    LinearGradient(
                        colors: [.black.opacity(1), .black.opacity(0)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
        )
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
}
