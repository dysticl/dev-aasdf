//
//  LeaderboardView.swift
//  Leaderboard mit neuem Design
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LevelingViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Shadow Background
                Color.shadowBackground
                    .ignoresSafeArea()
                
                if viewModel.isLoadingLeaderboard {
                    ProgressView()
                        .tint(Color.violetGlow)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Your Position
                            if let position = viewModel.userLeaderboardPosition {
                                VStack(spacing: 12) {
                                    Text("Your Rank")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.shadowTextSecondary)
                                        .tracking(1)
                                    
                                    Text("#\(position)")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundStyle(Color.violetGlow)
                                        .violetGlow()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                                .liquidGlass(cornerRadius: 20)
                                .padding(.horizontal, 24)
                                .padding(.top, 20)
                            }
                            
                            // Leaderboard Entries
                            ForEach(viewModel.leaderboard) { entry in
                                LeaderboardRow(entry: entry)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        await viewModel.loadLeaderboard()
                    }
                }
            }
            .navigationTitle("Hunter Rankings")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadLeaderboard()
            }
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Position
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Text("#\(entry.rankPosition)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(rankColor)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.username)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.shadowText)
                
                HStack(spacing: 8) {
                    Text("LV. \(entry.level)")
                        .font(.caption)
                        .foregroundStyle(Color.shadowTextSecondary)
                    
                    Text(entry.hunterRank.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(entry.hunterRank.color)
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", entry.totalScore))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.violetGlow)
                
                Text("Score")
                    .font(.caption2)
                    .foregroundStyle(Color.shadowTextSecondary)
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 16)
    }
    
    private var rankColor: Color {
        switch entry.rankPosition {
        case 1: return .yellow
        case 2: return Color(hex: "#C0C0C0") // Silver
        case 3: return Color(hex: "#CD7F32") // Bronze
        default: return Color.violetGlow
        }
    }
}

#Preview {
    LeaderboardView()
}
