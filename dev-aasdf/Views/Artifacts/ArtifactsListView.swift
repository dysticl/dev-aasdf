//
//  ArtifactsListView.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 06.12.25.
//

import SwiftUI

struct ArtifactsListView: View {
    @StateObject private var viewModel = ArtifactsViewModel()
    @State private var showCreateSheet = false

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            // Ambient Glow
            Circle()
                .fill(Color.purple.opacity(0.1))
                .blur(radius: 100)
                .offset(x: 100, y: -200)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Artifacts")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()

                    // Add Button
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Material.ultraThinMaterial))
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)

                // Filters ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPill(title: "All", isSelected: viewModel.selectedStatus == nil) {
                            viewModel.selectedStatus = nil
                            Task { await viewModel.fetchArtifacts() }
                        }

                        FilterPill(
                            title: "Pending", isSelected: viewModel.selectedStatus == "pending"
                        ) {
                            viewModel.selectedStatus = "pending"
                            Task { await viewModel.fetchArtifacts() }
                        }

                        FilterPill(
                            title: "In Progress",
                            isSelected: viewModel.selectedStatus == "in_progress"
                        ) {
                            viewModel.selectedStatus = "in_progress"
                            Task { await viewModel.fetchArtifacts() }
                        }

                        FilterPill(
                            title: "Completed", isSelected: viewModel.selectedStatus == "completed"
                        ) {
                            viewModel.selectedStatus = "completed"
                            Task { await viewModel.fetchArtifacts() }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }

                // List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.artifacts) { artifact in
                            NavigationLink(
                                destination: ArtifactDetailView(
                                    artifactId: artifact.id, viewModel: viewModel)
                            ) {
                                ArtifactCard(artifact: artifact)
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.fetchArtifacts()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchCategories()
                await viewModel.fetchArtifacts()
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateArtifactView(viewModel: viewModel)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Components

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Material.ultraThinMaterial)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct ArtifactCard: View {
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
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let categoryIcon = artifact.categoryIcon {  // Assuming extension or helper
                        Text(categoryIcon)  // Placeholder if not available directly
                    } else {
                        Image(systemName: "doc.text")  // Fallback
                    }

                    Text(artifact.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())

                    Spacer()

                    Text(artifact.status.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .clipShape(Capsule())
                }

                Text(artifact.taskName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)

                if let xp = artifact.aiEstimate?.estimatedXp {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("\(xp) XP")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding()
        }
        .background(Material.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Helper to safely access category icon if not in model directly
extension Artifact {
    var categoryIcon: String? {
        // In a real app we might map category string to icon or use what's in ViewModel
        // For now hardcode basic ones based on name or leave nil to use fallback
        switch category {
        case "Career": return "💼"
        case "Education": return "📚"
        case "Health": return "🏥"
        case "Finance": return "💰"
        case "Social": return "👥"
        case "Creative": return "🎨"
        case "Maintenance": return "🔧"
        default: return "📋"
        }
    }
}
