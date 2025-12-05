//
//  HealthModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import Foundation

struct TodayHealthResponse: Codable {
    let scoreDate: String
    let sleepScore: Double?
    let stepsScore: Double?
    let nutritionScoreNorm: Double?
    let healthTotalScore: Double?
    let hasData: Bool

    enum CodingKeys: String, CodingKey {
        case scoreDate = "score_date"
        case sleepScore = "sleep_score"
        case stepsScore = "steps_score"
        case nutritionScoreNorm = "nutrition_score_norm"
        case healthTotalScore = "health_total_score"
        case hasData = "has_data"
    }
}
