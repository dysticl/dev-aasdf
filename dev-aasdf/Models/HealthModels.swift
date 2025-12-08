//
//  HealthModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import Foundation

public struct TodayHealthResponse: Codable {
    public let scoreDate: String
    public let sleepScore: Double?
    public let stepsScore: Double?
    public let nutritionScoreNorm: Double?
    public let healthTotalScore: Double?
    public let hasData: Bool

    enum CodingKeys: String, CodingKey {
        case scoreDate = "score_date"
        case sleepScore = "sleep_score"
        case stepsScore = "steps_score"
        case nutritionScoreNorm = "nutrition_score_norm"
        case healthTotalScore = "health_total_score"
        case hasData = "has_data"
    }

    public init(
        scoreDate: String, sleepScore: Double?, stepsScore: Double?, nutritionScoreNorm: Double?,
        healthTotalScore: Double?, hasData: Bool
    ) {
        self.scoreDate = scoreDate
        self.sleepScore = sleepScore
        self.stepsScore = stepsScore
        self.nutritionScoreNorm = nutritionScoreNorm
        self.healthTotalScore = healthTotalScore
        self.hasData = hasData
    }
}
