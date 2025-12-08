//
//  LevelingModels.swift
//  dev-aasdf
//
//  Solo Leveling System Models
//  Based on leveling-system-v0-2.md concept
//

import Foundation
import SwiftUI

// MARK: - Hunter Rank Enum

public enum HunterRank: String, Codable, CaseIterable {
    case E = "E-Rank"
    case D = "D-Rank"
    case C = "C-Rank"
    case B = "B-Rank"
    case A = "A-Rank"
    case S = "S-Rank"

    public var displayName: String {
        return self.rawValue
    }

    public var color: Color {
        switch self {
        case .E: return Color.gray
        case .D: return Color(hex: "CD7F32")  // Bronze
        case .C: return Color(hex: "C0C0C0")  // Silver
        case .B: return Color(hex: "FFD700")  // Gold
        case .A: return Color(hex: "FF4500")  // Orange-Red
        case .S: return Color(hex: "9400D3")  // Purple (Shadow Monarch)
        }
    }

    public var icon: String {
        switch self {
        case .E: return "e.circle.fill"
        case .D: return "d.circle.fill"
        case .C: return "c.circle.fill"
        case .B: return "b.circle.fill"
        case .A: return "a.circle.fill"
        case .S: return "s.circle.fill"
        }
    }
}

// MARK: - Level Info

public struct LevelInfo: Codable {
    public let level: Int
    public let xpCurrent: Int
    public let xpToNextLevel: Int
    public let xpProgressPercent: Double
    public let totalXp: Int

    enum CodingKeys: String, CodingKey {
        case level
        case xpCurrent = "xp_current"
        case xpToNextLevel = "xp_to_next_level"
        case xpProgressPercent = "xp_progress_percent"
        case totalXp = "total_xp"
    }

    public var progressRatio: Double {
        return xpProgressPercent / 100.0
    }

    public init(
        level: Int, xpCurrent: Int, xpToNextLevel: Int, xpProgressPercent: Double, totalXp: Int
    ) {
        self.level = level
        self.xpCurrent = xpCurrent
        self.xpToNextLevel = xpToNextLevel
        self.xpProgressPercent = xpProgressPercent
        self.totalXp = totalXp
    }
}

// MARK: - Rank Info

public struct RankInfo: Codable {
    public let rank: HunterRank
    public let rankDisplay: String
    public let rankColor: String
    public let nextRank: HunterRank?
    public let levelsToNextRank: Int?

    enum CodingKeys: String, CodingKey {
        case rank
        case rankDisplay = "rank_display"
        case rankColor = "rank_color"
        case nextRank = "next_rank"
        case levelsToNextRank = "levels_to_next_rank"
    }

    public var color: Color {
        return rank.color
    }

    public init(
        rank: HunterRank, rankDisplay: String, rankColor: String, nextRank: HunterRank?,
        levelsToNextRank: Int?
    ) {
        self.rank = rank
        self.rankDisplay = rankDisplay
        self.rankColor = rankColor
        self.nextRank = nextRank
        self.levelsToNextRank = levelsToNextRank
    }
}

// MARK: - Score Breakdown

public struct ScoreBreakdown: Codable {
    public let bestSelfScore: Double
    public let disciplineScore: Double
    public let executionScore: Double
    public let weightBestself: Double
    public let weightDiscipline: Double
    public let weightExecution: Double
    public let totalScore: Double

    enum CodingKeys: String, CodingKey {
        case bestSelfScore = "best_self_score"
        case disciplineScore = "discipline_score"
        case executionScore = "execution_score"
        case weightBestself = "weight_bestself"
        case weightDiscipline = "weight_discipline"
        case weightExecution = "weight_execution"
        case totalScore = "total_score"
    }

    public init(
        bestSelfScore: Double, disciplineScore: Double, executionScore: Double,
        weightBestself: Double, weightDiscipline: Double, weightExecution: Double,
        totalScore: Double
    ) {
        self.bestSelfScore = bestSelfScore
        self.disciplineScore = disciplineScore
        self.executionScore = executionScore
        self.weightBestself = weightBestself
        self.weightDiscipline = weightDiscipline
        self.weightExecution = weightExecution
        self.totalScore = totalScore
    }
}

// MARK: - Dimension Progress

public struct DimensionInfo: Codable, Identifiable {
    public let dimCode: String
    public let name: String
    public let description: String?
    public let defaultWeight: Double
    public let targetValue: Double?
    public let gamma: Double
    public let isActive: Bool

    public var id: String { dimCode }

    enum CodingKeys: String, CodingKey {
        case dimCode = "dim_code"
        case name
        case description
        case defaultWeight = "default_weight"
        case targetValue = "target_value"
        case gamma
        case isActive = "is_active"
    }

    public var icon: String {
        switch dimCode {
        case "HEALTH": return "heart.fill"
        case "STRENGTH": return "dumbbell.fill"
        case "INTELLIGENCE": return "brain.head.profile"
        case "DISCIPLINE": return "flame.fill"
        case "FINANCE": return "dollarsign.circle.fill"
        case "SOCIAL": return "person.2.fill"
        default: return "star.fill"
        }
    }

    public var color: Color {
        switch dimCode {
        case "HEALTH": return .red
        case "STRENGTH": return .orange
        case "INTELLIGENCE": return .blue
        case "DISCIPLINE": return .purple
        case "FINANCE": return .green
        case "SOCIAL": return .cyan
        default: return .gray
        }
    }

    public init(
        dimCode: String, name: String, description: String?, defaultWeight: Double,
        targetValue: Double?, gamma: Double, isActive: Bool
    ) {
        self.dimCode = dimCode
        self.name = name
        self.description = description
        self.defaultWeight = defaultWeight
        self.targetValue = targetValue
        self.gamma = gamma
        self.isActive = isActive
    }
}

public struct UserDimensionProgress: Codable, Identifiable {
    public let dimCode: String
    public let name: String
    public let currentValue: Double
    public let targetValue: Double
    public let weight: Double
    public let gamma: Double
    public let progressRatio: Double
    public let weightedScore: Double

    public var id: String { dimCode }

    enum CodingKeys: String, CodingKey {
        case dimCode = "dim_code"
        case name
        case currentValue = "current_value"
        case targetValue = "target_value"
        case weight
        case gamma
        case progressRatio = "progress_ratio"
        case weightedScore = "weighted_score"
    }

    public var icon: String {
        switch dimCode {
        case "HEALTH": return "heart.fill"
        case "STRENGTH": return "dumbbell.fill"
        case "INTELLIGENCE": return "brain.head.profile"
        case "DISCIPLINE": return "flame.fill"
        case "FINANCE": return "dollarsign.circle.fill"
        case "SOCIAL": return "person.2.fill"
        default: return "star.fill"
        }
    }

    public var color: Color {
        switch dimCode {
        case "HEALTH": return .red
        case "STRENGTH": return .orange
        case "INTELLIGENCE": return .blue
        case "DISCIPLINE": return .purple
        case "FINANCE": return .green
        case "SOCIAL": return .cyan
        default: return .gray
        }
    }

    public var progressPercent: Double {
        return progressRatio * 100
    }

    public init(
        dimCode: String, name: String, currentValue: Double, targetValue: Double, weight: Double,
        gamma: Double, progressRatio: Double, weightedScore: Double
    ) {
        self.dimCode = dimCode
        self.name = name
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.weight = weight
        self.gamma = gamma
        self.progressRatio = progressRatio
        self.weightedScore = weightedScore
    }
}

// MARK: - Complete User Stats Response

public struct UserStatsResponse: Codable {
    public let userId: String
    public let username: String
    public let level: LevelInfo
    public let rank: RankInfo
    public let scores: ScoreBreakdown
    public let currentStreak: Int
    public let longestStreak: Int
    public let totalTasksCompleted: Int
    public let totalArtifactsCompleted: Int
    public let lastLevelUp: String?
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case level
        case rank
        case scores
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case totalTasksCompleted = "total_tasks_completed"
        case totalArtifactsCompleted = "total_artifacts_completed"
        case lastLevelUp = "last_level_up"
        case updatedAt = "updated_at"
    }

    public init(
        userId: String, username: String, level: LevelInfo, rank: RankInfo, scores: ScoreBreakdown,
        currentStreak: Int, longestStreak: Int, totalTasksCompleted: Int,
        totalArtifactsCompleted: Int, lastLevelUp: String?, updatedAt: String?
    ) {
        self.userId = userId
        self.username = username
        self.level = level
        self.rank = rank
        self.scores = scores
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalTasksCompleted = totalTasksCompleted
        self.totalArtifactsCompleted = totalArtifactsCompleted
        self.lastLevelUp = lastLevelUp
        self.updatedAt = updatedAt
    }
}

// MARK: - Dimensions Response

public struct DimensionsListResponse: Codable {
    public let dimensions: [DimensionInfo]
    public let total: Int

    public init(dimensions: [DimensionInfo], total: Int) {
        self.dimensions = dimensions
        self.total = total
    }
}

public struct UserDimensionsResponse: Codable {
    public let userId: String
    public let dimensions: [UserDimensionProgress]
    public let bestSelfScore: Double

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case dimensions
        case bestSelfScore = "best_self_score"
    }

    public init(userId: String, dimensions: [UserDimensionProgress], bestSelfScore: Double) {
        self.userId = userId
        self.dimensions = dimensions
        self.bestSelfScore = bestSelfScore
    }
}

// MARK: - Leaderboard

public struct LeaderboardEntry: Codable, Identifiable {
    public let rankPosition: Int
    public let userId: String
    public let username: String
    public let level: Int
    public let hunterRank: HunterRank
    public let totalScore: Double
    public let profilePicUrl: String?

    public var id: String { userId }

    enum CodingKeys: String, CodingKey {
        case rankPosition = "rank_position"
        case userId = "user_id"
        case username
        case level
        case hunterRank = "hunter_rank"
        case totalScore = "total_score"
        case profilePicUrl = "profile_pic_url"
    }

    public init(
        rankPosition: Int, userId: String, username: String, level: Int, hunterRank: HunterRank,
        totalScore: Double, profilePicUrl: String?
    ) {
        self.rankPosition = rankPosition
        self.userId = userId
        self.username = username
        self.level = level
        self.hunterRank = hunterRank
        self.totalScore = totalScore
        self.profilePicUrl = profilePicUrl
    }
}

public struct LeaderboardResponse: Codable {
    public let entries: [LeaderboardEntry]
    public let userPosition: Int?
    public let totalUsers: Int

    enum CodingKeys: String, CodingKey {
        case entries
        case userPosition = "user_position"
        case totalUsers = "total_users"
    }

    public init(entries: [LeaderboardEntry], userPosition: Int?, totalUsers: Int) {
        self.entries = entries
        self.userPosition = userPosition
        self.totalUsers = totalUsers
    }
}

// MARK: - Level Up Event

public struct LevelUpEvent: Codable {
    public let oldLevel: Int
    public let newLevel: Int
    public let rankChanged: Bool
    public let oldRank: HunterRank?
    public let newRank: HunterRank?
    public let xpAwarded: Int
    public let message: String

    enum CodingKeys: String, CodingKey {
        case oldLevel = "old_level"
        case newLevel = "new_level"
        case rankChanged = "rank_changed"
        case oldRank = "old_rank"
        case newRank = "new_rank"
        case xpAwarded = "xp_awarded"
        case message
    }

    public init(
        oldLevel: Int, newLevel: Int, rankChanged: Bool, oldRank: HunterRank?, newRank: HunterRank?,
        xpAwarded: Int, message: String
    ) {
        self.oldLevel = oldLevel
        self.newLevel = newLevel
        self.rankChanged = rankChanged
        self.oldRank = oldRank
        self.newRank = newRank
        self.xpAwarded = xpAwarded
        self.message = message
    }
}
