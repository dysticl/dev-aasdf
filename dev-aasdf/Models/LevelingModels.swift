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

enum HunterRank: String, Codable, CaseIterable {
    case E = "E-Rank"
    case D = "D-Rank"
    case C = "C-Rank"
    case B = "B-Rank"
    case A = "A-Rank"
    case S = "S-Rank"

    var displayName: String {
        return self.rawValue
    }

    var color: Color {
        switch self {
        case .E: return Color.gray
        case .D: return Color(hex: "CD7F32")  // Bronze
        case .C: return Color(hex: "C0C0C0")  // Silver
        case .B: return Color(hex: "FFD700")  // Gold
        case .A: return Color(hex: "FF4500")  // Orange-Red
        case .S: return Color(hex: "9400D3")  // Purple (Shadow Monarch)
        }
    }

    var icon: String {
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

struct LevelInfo: Codable {
    let level: Int
    let xpCurrent: Int
    let xpToNextLevel: Int
    let xpProgressPercent: Double
    let totalXp: Int

    enum CodingKeys: String, CodingKey {
        case level
        case xpCurrent = "xp_current"
        case xpToNextLevel = "xp_to_next_level"
        case xpProgressPercent = "xp_progress_percent"
        case totalXp = "total_xp"
    }

    var progressRatio: Double {
        return xpProgressPercent / 100.0
    }
}

// MARK: - Rank Info

struct RankInfo: Codable {
    let rank: HunterRank
    let rankDisplay: String
    let rankColor: String
    let nextRank: HunterRank?
    let levelsToNextRank: Int?

    enum CodingKeys: String, CodingKey {
        case rank
        case rankDisplay = "rank_display"
        case rankColor = "rank_color"
        case nextRank = "next_rank"
        case levelsToNextRank = "levels_to_next_rank"
    }

    var color: Color {
        return rank.color
    }
}

// MARK: - Score Breakdown

struct ScoreBreakdown: Codable {
    let bestSelfScore: Double
    let disciplineScore: Double
    let executionScore: Double
    let weightBestself: Double
    let weightDiscipline: Double
    let weightExecution: Double
    let totalScore: Double

    enum CodingKeys: String, CodingKey {
        case bestSelfScore = "best_self_score"
        case disciplineScore = "discipline_score"
        case executionScore = "execution_score"
        case weightBestself = "weight_bestself"
        case weightDiscipline = "weight_discipline"
        case weightExecution = "weight_execution"
        case totalScore = "total_score"
    }
}

// MARK: - Dimension Progress

struct DimensionInfo: Codable, Identifiable {
    let dimCode: String
    let name: String
    let description: String?
    let defaultWeight: Double
    let targetValue: Double?
    let gamma: Double
    let isActive: Bool

    var id: String { dimCode }

    enum CodingKeys: String, CodingKey {
        case dimCode = "dim_code"
        case name
        case description
        case defaultWeight = "default_weight"
        case targetValue = "target_value"
        case gamma
        case isActive = "is_active"
    }

    var icon: String {
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

    var color: Color {
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
}

struct UserDimensionProgress: Codable, Identifiable {
    let dimCode: String
    let name: String
    let currentValue: Double
    let targetValue: Double
    let weight: Double
    let gamma: Double
    let progressRatio: Double
    let weightedScore: Double

    var id: String { dimCode }

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

    var icon: String {
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

    var color: Color {
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

    var progressPercent: Double {
        return progressRatio * 100
    }
}

// MARK: - Complete User Stats Response

struct UserStatsResponse: Codable {
    let userId: String
    let username: String
    let level: LevelInfo
    let rank: RankInfo
    let scores: ScoreBreakdown
    let currentStreak: Int
    let longestStreak: Int
    let totalTasksCompleted: Int
    let totalArtifactsCompleted: Int
    let lastLevelUp: String?
    let updatedAt: String?

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
}

// MARK: - Dimensions Response

struct DimensionsListResponse: Codable {
    let dimensions: [DimensionInfo]
    let total: Int
}

struct UserDimensionsResponse: Codable {
    let userId: String
    let dimensions: [UserDimensionProgress]
    let bestSelfScore: Double

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case dimensions
        case bestSelfScore = "best_self_score"
    }
}

// MARK: - Leaderboard

struct LeaderboardEntry: Codable, Identifiable {
    let rankPosition: Int
    let userId: String
    let username: String
    let level: Int
    let hunterRank: HunterRank
    let totalScore: Double
    let profilePicUrl: String?

    var id: String { userId }

    enum CodingKeys: String, CodingKey {
        case rankPosition = "rank_position"
        case userId = "user_id"
        case username
        case level
        case hunterRank = "hunter_rank"
        case totalScore = "total_score"
        case profilePicUrl = "profile_pic_url"
    }
}

struct LeaderboardResponse: Codable {
    let entries: [LeaderboardEntry]
    let userPosition: Int?
    let totalUsers: Int

    enum CodingKeys: String, CodingKey {
        case entries
        case userPosition = "user_position"
        case totalUsers = "total_users"
    }
}

// MARK: - Level Up Event

struct LevelUpEvent: Codable {
    let oldLevel: Int
    let newLevel: Int
    let rankChanged: Bool
    let oldRank: HunterRank?
    let newRank: HunterRank?
    let xpAwarded: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case oldLevel = "old_level"
        case newLevel = "new_level"
        case rankChanged = "rank_changed"
        case oldRank = "old_rank"
        case newRank = "new_rank"
        case xpAwarded = "xp_awarded"
        case message
    }
}
