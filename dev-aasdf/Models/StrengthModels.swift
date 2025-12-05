//
//  StrengthModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import Foundation

struct TodayStrengthResponse: Codable {
    let scoreDate: String
    let strengthKraftScore: Double
    let strengthCardioScore: Double
    let strengthTotalScore: Double
    let hasData: Bool

    enum CodingKeys: String, CodingKey {
        case scoreDate = "score_date"
        case strengthKraftScore = "strength_kraft_score"
        case strengthCardioScore = "strength_cardio_score"
        case strengthTotalScore = "strength_total_score"
        case hasData = "has_data"
    }
}
