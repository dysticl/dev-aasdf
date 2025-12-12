//
//  LevelingViewModel.swift
//  dev-aasdf
//
//  Solo Leveling System ViewModel
//  Manages user stats, levels, ranks, and dimensions
//

import Combine
import SwiftUI

@MainActor
class LevelingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var userStats: UserStatsResponse?
    @Published var dimensions: [UserDimensionProgress] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var userLeaderboardPosition: Int?

    @Published var isLoading = false
    @Published var isLoadingLeaderboard = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    @Published var daystrikeCurrent: Int?

    // Level up animation
    @Published var showLevelUp = false
    @Published var levelUpEvent: LevelUpEvent?

    private let apiService = APIService.shared

    // MARK: - Computed Properties

    var level: Int {
        userStats?.level.level ?? 1
    }

    var xpCurrent: Int {
        userStats?.level.xpCurrent ?? 0
    }

    var xpToNextLevel: Int {
        userStats?.level.xpToNextLevel ?? 100
    }

    var xpProgress: Double {
        userStats?.level.progressRatio ?? 0.0
    }

    var hunterRank: HunterRank {
        userStats?.rank.rank ?? .E
    }

    var rankDisplay: String {
        userStats?.rank.rankDisplay ?? "E-Rank Hunter"
    }

    var totalScore: Double {
        userStats?.scores.totalScore ?? 0.0
    }

    var bestSelfScore: Double {
        userStats?.scores.bestSelfScore ?? 0.0
    }

    var disciplineScore: Double {
        userStats?.scores.disciplineScore ?? 0.0
    }

    var executionScore: Double {
        userStats?.scores.executionScore ?? 0.0
    }

    var currentStreak: Int {
        if let ds = daystrikeCurrent { return ds }
        return userStats?.currentStreak ?? 0
    }

    var longestStreak: Int {
        userStats?.longestStreak ?? 0
    }

    var username: String {
        userStats?.username ?? "Hunter"
    }

    // MARK: - Data Loading

    func loadAllData() async {
        isLoading = true
        await loadUserStats()
        await loadDimensions()
        await loadCurrentDaystrike()
        isLoading = false
    }

    func loadUserStats() async {
        do {
            let stats = try await apiService.fetchUserStats()
            self.userStats = stats
        } catch {
            errorMessage = "Failed to load stats: \(error.localizedDescription)"
            showError = true
            print("Failed to load user stats: \(error)")
        }
    }

    func loadDimensions() async {
        do {
            let response = try await apiService.fetchUserDimensions()
            self.dimensions = response.dimensions
        } catch {
            print("Failed to load dimensions: \(error)")
            // Don't show error for dimensions, not critical
        }
    }
    
    func loadCurrentDaystrike() async {
        do {
            // Prefer userId from userStats if available
            if let userId = userStats?.userId {
                let current = try await apiService.fetchCurrentDaystrike(userId: userId)
                self.daystrikeCurrent = current
            } else {
                // Fallback: try loading stats first to get userId
                let stats = try await apiService.fetchUserStats()
                self.userStats = stats
                let current = try await apiService.fetchCurrentDaystrike(userId: stats.userId)
                self.daystrikeCurrent = current
            }
        } catch {
            // Silent fail for daystrike; don't show blocking error
            print("Failed to load current daystrike: \(error)")
        }
    }

    func loadLeaderboard(limit: Int = 20) async {
        isLoadingLeaderboard = true
        do {
            let response = try await apiService.fetchLeaderboard(limit: limit)
            self.leaderboard = response.entries
            self.userLeaderboardPosition = response.userPosition
        } catch {
            print("Failed to load leaderboard: \(error)")
        }
        isLoadingLeaderboard = false
    }

    func refresh() async {
        await loadAllData()
    }

    // MARK: - Level Up Animation

    func handleLevelUp(event: LevelUpEvent) {
        self.levelUpEvent = event
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            self.showLevelUp = true
        }

        // Auto dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showLevelUp = false
            }
        }
    }

    func dismissLevelUp() {
        withAnimation {
            showLevelUp = false
        }
    }
}

// MARK: - Preview Helper

extension LevelingViewModel {
    static var preview: LevelingViewModel {
        let vm = LevelingViewModel()
        vm.userStats = UserStatsResponse(
            userId: "preview-user",
            username: "@ShadowMonarch",
            level: LevelInfo(
                level: 42,
                xpCurrent: 750,
                xpToNextLevel: 1000,
                xpProgressPercent: 75.0,
                totalXp: 25000
            ),
            rank: RankInfo(
                rank: .B,
                rankDisplay: "B-Rank Hunter",
                rankColor: "#FFD700",
                nextRank: .A,
                levelsToNextRank: 24
            ),
            scores: ScoreBreakdown(
                bestSelfScore: 68.5,
                disciplineScore: 82.0,
                executionScore: 75.3,
                weightBestself: 0.4,
                weightDiscipline: 0.3,
                weightExecution: 0.3,
                totalScore: 74.5
            ),
            currentStreak: 12,
            longestStreak: 45,
            totalTasksCompleted: 156,
            totalArtifactsCompleted: 23,
            lastLevelUp: nil,
            updatedAt: nil
        )
        vm.dimensions = [
            UserDimensionProgress(
                dimCode: "STRENGTH",
                name: "Strength",
                currentValue: 98.0,
                targetValue: 140.0,
                weight: 0.2,
                gamma: 1.5,
                progressRatio: 0.7,
                weightedScore: 0.117
            ),
            UserDimensionProgress(
                dimCode: "HEALTH",
                name: "Health",
                currentValue: 85.0,
                targetValue: 100.0,
                weight: 0.2,
                gamma: 1.5,
                progressRatio: 0.85,
                weightedScore: 0.157
            ),
            UserDimensionProgress(
                dimCode: "INTELLIGENCE",
                name: "Intelligence",
                currentValue: 0.75,
                targetValue: 1.0,
                weight: 0.2,
                gamma: 1.5,
                progressRatio: 0.75,
                weightedScore: 0.13
            ),
            UserDimensionProgress(
                dimCode: "DISCIPLINE",
                name: "Discipline",
                currentValue: 90.0,
                targetValue: 100.0,
                weight: 0.2,
                gamma: 1.5,
                progressRatio: 0.9,
                weightedScore: 0.171
            ),
            UserDimensionProgress(
                dimCode: "FINANCE",
                name: "Finance",
                currentValue: 2500.0,
                targetValue: 5000.0,
                weight: 0.1,
                gamma: 1.5,
                progressRatio: 0.5,
                weightedScore: 0.035
            ),
            UserDimensionProgress(
                dimCode: "SOCIAL",
                name: "Social",
                currentValue: 45.0,
                targetValue: 100.0,
                weight: 0.1,
                gamma: 1.5,
                progressRatio: 0.45,
                weightedScore: 0.03
            )
        ]
        return vm
    }
}

