//
//  RewardModels.swift
//  dev-aasdf
//
//  Adaptive Reward System Models
//  Based on Reward-System-Whitepaper.md and OpenAPI schemas
//

import Foundation
import SwiftUI

// MARK: - Enums

/// Rarity tier for wishes
public enum WishRarity: String, Codable, CaseIterable {
    case COMMON
    case RARE
    case LEGENDARY

    public var displayName: String {
        switch self {
        case .COMMON: return "Common"
        case .RARE: return "Rare"
        case .LEGENDARY: return "Legendary"
        }
    }

    public var color: Color {
        switch self {
        case .COMMON: return .gray
        case .RARE: return .blue
        case .LEGENDARY: return .purple
        }
    }

    public var glowColor: Color {
        switch self {
        case .COMMON: return .gray.opacity(0.3)
        case .RARE: return .blue.opacity(0.5)
        case .LEGENDARY: return .purple.opacity(0.7)
        }
    }

    public var icon: String {
        switch self {
        case .COMMON: return "circle.fill"
        case .RARE: return "diamond.fill"
        case .LEGENDARY: return "star.fill"
        }
    }
}

/// Volatility/addiction risk level
public enum VolatilityRisk: String, Codable, CaseIterable {
    case LOW
    case MEDIUM
    case HIGH

    public var displayName: String {
        switch self {
        case .LOW: return "Low Risk"
        case .MEDIUM: return "Medium Risk"
        case .HIGH: return "High Risk"
        }
    }

    public var color: Color {
        switch self {
        case .LOW: return .green
        case .MEDIUM: return .yellow
        case .HIGH: return .red
        }
    }
}

/// Status of a wish
public enum WishStatus: String, Codable {
    case AVAILABLE
    case LOCKED
    case CLAIMED
    case COOLDOWN

    public var displayName: String {
        switch self {
        case .AVAILABLE: return "Available"
        case .LOCKED: return "Locked"
        case .CLAIMED: return "Claimed"
        case .COOLDOWN: return "Cooldown"
        }
    }

    public var icon: String {
        switch self {
        case .AVAILABLE: return "checkmark.circle.fill"
        case .LOCKED: return "lock.fill"
        case .CLAIMED: return "gift.fill"
        case .COOLDOWN: return "clock.fill"
        }
    }
}

/// Activity type for reward engine
public enum ActivityType: String, Codable {
    case daily
    case artifact
    case custom
}

// MARK: - Wish History

public struct WishHistory: Codable {
    public let timesUsed: Int
    public let timesFailed: Int
    public let avgSatisfaction: Double?
    public let desensTrend: Double?

    enum CodingKeys: String, CodingKey {
        case timesUsed = "times_used"
        case timesFailed = "times_failed"
        case avgSatisfaction = "avg_satisfaction"
        case desensTrend = "desens_trend"
    }

    public init(timesUsed: Int = 0, timesFailed: Int = 0, avgSatisfaction: Double? = nil, desensTrend: Double? = nil) {
        self.timesUsed = timesUsed
        self.timesFailed = timesFailed
        self.avgSatisfaction = avgSatisfaction
        self.desensTrend = desensTrend
    }
}

// MARK: - Wish Response (Main Model)

public struct WishResponse: Codable, Identifiable {
    public let wishId: String
    public let userId: String
    public let title: String
    public let description: String?
    public let baseDopaminePotential: Int
    public let rarity: WishRarity
    public let volatilityRisk: VolatilityRisk
    public let cooldownHours: Int
    public let longtermImpact: Int
    public let history: WishHistory?
    public let lastUsed: String?
    public let currentXpCost: Int?
    public let isActive: Bool
    public let status: WishStatus
    public let createdAt: String?
    public let updatedAt: String?
    public let desensAlert: Bool
    public let cooldownRemainingHours: Int?

    public var id: String { wishId }

    enum CodingKeys: String, CodingKey {
        case wishId = "wish_id"
        case userId = "user_id"
        case title
        case description
        case baseDopaminePotential = "base_dopamine_potential"
        case rarity
        case volatilityRisk = "volatility_risk"
        case cooldownHours = "cooldown_hours"
        case longtermImpact = "longterm_impact"
        case history
        case lastUsed = "last_used"
        case currentXpCost = "current_xp_cost"
        case isActive = "is_active"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case desensAlert = "desens_alert"
        case cooldownRemainingHours = "cooldown_remaining_hours"
    }

    /// Whether this wish can be claimed (affordable and available)
    public func isClaimable(userXp: Int) -> Bool {
        guard status == .AVAILABLE else { return false }
        guard let cost = currentXpCost else { return false }
        return userXp >= cost
    }

    /// Display text for XP cost
    public var xpCostDisplay: String {
        if let cost = currentXpCost {
            return "\(cost) XP"
        }
        return "-- XP"
    }

    /// Dopamine potential as percentage string
    public var dopaminePotentialDisplay: String {
        return "\(baseDopaminePotential)%"
    }
}

// MARK: - Wish List Response

public struct WishListResponse: Codable {
    public let wishes: [WishResponse]
    public let total: Int
    public let activeCount: Int
    public let availableCount: Int

    enum CodingKeys: String, CodingKey {
        case wishes
        case total
        case activeCount = "active_count"
        case availableCount = "available_count"
    }

    public init(wishes: [WishResponse] = [], total: Int = 0, activeCount: Int = 0, availableCount: Int = 0) {
        self.wishes = wishes
        self.total = total
        self.activeCount = activeCount
        self.availableCount = availableCount
    }
}

// MARK: - Wish Create Request

public struct WishCreateRequest: Codable {
    public let title: String
    public let description: String?
    public let baseDopaminePotential: Int
    public let rarity: WishRarity
    public let volatilityRisk: VolatilityRisk
    public let cooldownHours: Int
    public let longtermImpact: Int

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case baseDopaminePotential = "base_dopamine_potential"
        case rarity
        case volatilityRisk = "volatility_risk"
        case cooldownHours = "cooldown_hours"
        case longtermImpact = "longterm_impact"
    }

    public init(
        title: String,
        description: String? = nil,
        baseDopaminePotential: Int = 50,
        rarity: WishRarity = .COMMON,
        volatilityRisk: VolatilityRisk = .LOW,
        cooldownHours: Int = 24,
        longtermImpact: Int = 50
    ) {
        self.title = title
        self.description = description
        self.baseDopaminePotential = baseDopaminePotential
        self.rarity = rarity
        self.volatilityRisk = volatilityRisk
        self.cooldownHours = cooldownHours
        self.longtermImpact = longtermImpact
    }
}

// MARK: - Wish Claim (Simple PUT)

public struct WishClaimUpdate: Codable {
    public let satisfactionScore: Double

    enum CodingKeys: String, CodingKey {
        case satisfactionScore = "satisfaction_score"
    }

    public init(satisfactionScore: Double) {
        self.satisfactionScore = satisfactionScore
    }
}

public struct WishClaimSimpleResponse: Codable {
    public let message: String
    public let wishId: String
    public let timesUsed: Int
    public let newAvgSatisfaction: Double?
    public let cooldownUntil: String?
    public let status: WishStatus

    enum CodingKeys: String, CodingKey {
        case message
        case wishId = "wish_id"
        case timesUsed = "times_used"
        case newAvgSatisfaction = "new_avg_satisfaction"
        case cooldownUntil = "cooldown_until"
        case status
    }
}

// MARK: - User Stats Snapshot (for Reward Engine)

public struct RewardUserStatsSnapshot: Codable {
    public let userId: String
    public let xpCurrent: Int
    public let level: Int
    public let xpToNextLevel: Int?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case xpCurrent = "xp_current"
        case level
        case xpToNextLevel = "xp_to_next_level"
    }
}

// MARK: - Unlockable Wish

public struct UnlockableWish: Codable, Identifiable {
    public let wishId: String
    public let title: String
    public let currentXpCost: Int?
    public let rarity: WishRarity
    public let volatilityRisk: VolatilityRisk
    public let baseDopaminePotential: Int
    public let status: WishStatus
    public let isAffordable: Bool

    public var id: String { wishId }

    enum CodingKeys: String, CodingKey {
        case wishId = "wish_id"
        case title
        case currentXpCost = "current_xp_cost"
        case rarity
        case volatilityRisk = "volatility_risk"
        case baseDopaminePotential = "base_dopamine_potential"
        case status
        case isAffordable = "is_affordable"
    }
}

// MARK: - Activity Completed Request/Response

public struct ActivityCompletedRequest: Codable {
    public let userId: String
    public let activityId: String
    public let activityType: ActivityType
    public let executionId: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case activityId = "activity_id"
        case activityType = "activity_type"
        case executionId = "execution_id"
    }
}

public struct ActivityCompletedResponse: Codable {
    public let message: String
    public let executionId: String
    public let activityType: String
    public let userStats: RewardUserStatsSnapshot
    public let unlockableWishes: [UnlockableWish]
    public let totalUnlockable: Int
    public let currentPhase: Int

    enum CodingKeys: String, CodingKey {
        case message
        case executionId = "execution_id"
        case activityType = "activity_type"
        case userStats = "user_stats"
        case unlockableWishes = "unlockable_wishes"
        case totalUnlockable = "total_unlockable"
        case currentPhase = "current_phase"
    }
}

// MARK: - Reward Claim Request/Response (Full Engine)

public struct RewardClaimRequest: Codable {
    public let userId: String
    public let satisfactionScore: Double

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case satisfactionScore = "satisfaction_score"
    }

    public init(userId: String, satisfactionScore: Double) {
        self.userId = userId
        self.satisfactionScore = satisfactionScore
    }
}

public struct RewardClaimLogEntry: Codable {
    public let claimId: String
    public let userId: String
    public let rewardId: String
    public let finalRv: Double
    public let xpCost: Int
    public let satisfactionScore: Double
    public let phaseAtClaim: Int
    public let wasHighDp: Bool
    public let claimedAt: String

    enum CodingKeys: String, CodingKey {
        case claimId = "claim_id"
        case userId = "user_id"
        case rewardId = "reward_id"
        case finalRv = "final_rv"
        case xpCost = "xp_cost"
        case satisfactionScore = "satisfaction_score"
        case phaseAtClaim = "phase_at_claim"
        case wasHighDp = "was_high_dp"
        case claimedAt = "claimed_at"
    }
}

public struct RewardClaimResponse: Codable {
    public let message: String
    public let claimLog: RewardClaimLogEntry
    public let rvBase: Double
    public let rvAdjusted: Double
    public let rvFinal: Double
    public let xpCost: Int
    public let xpBefore: Int
    public let xpAfter: Int
    public let level: Int
    public let wishTitle: String
    public let wishNewStatus: String
    public let wishTimesUsed: Int
    public let mlRecommendedAction: String?
    public let desensitizationTrend: Double?
    public let predictedPhase: Int?

    enum CodingKeys: String, CodingKey {
        case message
        case claimLog = "claim_log"
        case rvBase = "rv_base"
        case rvAdjusted = "rv_adjusted"
        case rvFinal = "rv_final"
        case xpCost = "xp_cost"
        case xpBefore = "xp_before"
        case xpAfter = "xp_after"
        case level
        case wishTitle = "wish_title"
        case wishNewStatus = "wish_new_status"
        case wishTimesUsed = "wish_times_used"
        case mlRecommendedAction = "ml_recommended_action"
        case desensitizationTrend = "desensitization_trend"
        case predictedPhase = "predicted_phase"
    }
}

// MARK: - Penalty Info

public struct PenaltyInfo: Codable {
    public let penaltyId: String
    public let penaltyType: String
    public let severityLevel: Int
    public let xpLoss: Int
    public let daysSinceLast: Int?

    enum CodingKeys: String, CodingKey {
        case penaltyId = "penalty_id"
        case penaltyType = "penalty_type"
        case severityLevel = "severity_level"
        case xpLoss = "xp_loss"
        case daysSinceLast = "days_since_last"
    }
}

// MARK: - Recovery Info

public struct RecoveryInfo: Codable {
    public let circuitBreakerActivated: Bool
    public let cbUntil: String?
    public let highDpRewardsLocked: Int
    public let lowRiskAvailable: Int
    public let recoveryMessage: String?

    enum CodingKeys: String, CodingKey {
        case circuitBreakerActivated = "circuit_breaker_activated"
        case cbUntil = "cb_until"
        case highDpRewardsLocked = "high_dp_rewards_locked"
        case lowRiskAvailable = "low_risk_available"
        case recoveryMessage = "recovery_message"
    }
}

// MARK: - Activity Missed Request/Response

public struct ActivityMissedRequest: Codable {
    public let userId: String
    public let activityId: String
    public let activityType: ActivityType

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case activityId = "activity_id"
        case activityType = "activity_type"
    }
}

public struct ActivityMissedResponse: Codable {
    public let message: String
    public let penalty: PenaltyInfo
    public let xpBefore: Int
    public let xpAfter: Int
    public let currentEscalationLevel: Int
    public let nextPenaltyXp: Int
    public let daysUntilRecovery: Int
    public let recovery: RecoveryInfo
    public let mlMonitoringActive: Bool

    enum CodingKeys: String, CodingKey {
        case message
        case penalty
        case xpBefore = "xp_before"
        case xpAfter = "xp_after"
        case currentEscalationLevel = "current_escalation_level"
        case nextPenaltyXp = "next_penalty_xp"
        case daysUntilRecovery = "days_until_recovery"
        case recovery
        case mlMonitoringActive = "ml_monitoring_active"
    }
}

// MARK: - Reward State Response

public struct RewardStateResponse: Codable {
    public let stateId: String
    public let userId: String
    public let wishId: String
    public let rvBase: Double
    public let rvAdjusted: Double
    public let rvFinal: Double
    public let xpCost: Int
    public let currentCf: Double
    public let currentPm: Double
    public let calculatedAt: String
    public let isAffordable: Bool?
    public let userXp: Int?

    enum CodingKeys: String, CodingKey {
        case stateId = "state_id"
        case userId = "user_id"
        case wishId = "wish_id"
        case rvBase = "rv_base"
        case rvAdjusted = "rv_adjusted"
        case rvFinal = "rv_final"
        case xpCost = "xp_cost"
        case currentCf = "current_cf"
        case currentPm = "current_pm"
        case calculatedAt = "calculated_at"
        case isAffordable = "is_affordable"
        case userXp = "user_xp"
    }
}

// MARK: - Motivation State

public struct RewardMotivationState: Codable {
    public let dopamineSensitivity: Double
    public let motivationPhase: Int
    public let haHistoryAdjustment: Double
    public let toleranceRisk: Double
    public let highDpClaims24h: Int
    public let circuitBreakerActive: Bool
    public let circuitBreakerUntil: String?

    enum CodingKeys: String, CodingKey {
        case dopamineSensitivity = "dopamine_sensitivity"
        case motivationPhase = "motivation_phase"
        case haHistoryAdjustment = "ha_history_adjustment"
        case toleranceRisk = "tolerance_risk"
        case highDpClaims24h = "high_dp_claims_24h"
        case circuitBreakerActive = "circuit_breaker_active"
        case circuitBreakerUntil = "circuit_breaker_until"
    }

    /// Phase description based on Wall Street Cheat Sheet
    public var phaseDescription: String {
        switch motivationPhase {
        case 1: return "Disbelief"
        case 2: return "Hope"
        case 3: return "Optimism"
        case 4: return "Belief"
        case 5: return "Thrill"
        case 6: return "Euphoria"
        case 7: return "Neutral"
        case 8: return "Complacency"
        case 9: return "Anxiety"
        case 10: return "Denial"
        case 11: return "Panic"
        case 12: return "Capitulation"
        case 13: return "Depression"
        default: return "Unknown"
        }
    }

    /// Phase color for UI
    public var phaseColor: Color {
        switch motivationPhase {
        case 1...4: return .blue      // Recovery/Growth phase
        case 5, 6: return .green      // Peak phase
        case 7: return .gray          // Neutral
        case 8...10: return .yellow   // Warning phase
        case 11...13: return .red     // Danger/Recovery phase
        default: return .gray
        }
    }
}

// MARK: - Receptor Context

public struct RewardReceptorContext: Codable {
    public let cleanDaysLast30: Int
    public let dirtyDaysLast30: Int
    public let netCleanScore: Double
    public let dopamineBaseline: Double
    public let lastRelapseDate: String?
    public let previousStreakBeforeRelapse: Int?
    public let daysSinceRelapse: Int?

    enum CodingKeys: String, CodingKey {
        case cleanDaysLast30 = "clean_days_last_30"
        case dirtyDaysLast30 = "dirty_days_last_30"
        case netCleanScore = "net_clean_score"
        case dopamineBaseline = "dopamine_baseline"
        case lastRelapseDate = "last_relapse_date"
        case previousStreakBeforeRelapse = "previous_streak_before_relapse"
        case daysSinceRelapse = "days_since_relapse"
    }
}

// MARK: - Progress State

public struct RewardProgressState: Codable {
    public let level: Int
    public let xpCurrent: Int
    public let xpToNextLevel: Int
    public let currentStreak: Int
    public let longestStreak: Int
    public let totalTasksCompleted: Int
    public let totalTasksFailed: Int
    public let lastLevelUp: String?

    enum CodingKeys: String, CodingKey {
        case level
        case xpCurrent = "xp_current"
        case xpToNextLevel = "xp_to_next_level"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case totalTasksCompleted = "total_tasks_completed"
        case totalTasksFailed = "total_tasks_failed"
        case lastLevelUp = "last_level_up"
    }

    /// XP progress as ratio (0-1)
    public var xpProgressRatio: Double {
        guard xpToNextLevel > 0 else { return 0 }
        return Double(xpCurrent) / Double(xpToNextLevel)
    }
}

// MARK: - Full Reward User Profile

public struct RewardUserProfileResponse: Codable {
    public let userId: String
    public let username: String
    public let profilePicUrl: String?
    public let motivation: RewardMotivationState
    public let receptor: RewardReceptorContext
    public let progression: RewardProgressState

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case profilePicUrl = "profile_pic_url"
        case motivation
        case receptor
        case progression
    }
}

// MARK: - Reward Engine Health

public struct RewardEngineHealthResponse: Codable {
    public let status: String
    public let services: [String: Bool]?
    public let message: String

    public var isHealthy: Bool {
        return status == "healthy"
    }
}

// MARK: - Wish Delete Response

public struct WishDeleteResponse: Codable {
    public let message: String
    public let wishId: String

    enum CodingKeys: String, CodingKey {
        case message
        case wishId = "wish_id"
    }
}
