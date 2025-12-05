//
//  IntelligenceModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import Foundation

struct TodayIntelligenceResponse: Codable {
    let scoreDate: String
    let avgGradeValue: Double?
    let intelligenceTotalScore: Double?
    let hasData: Bool

    enum CodingKeys: String, CodingKey {
        case scoreDate = "score_date"
        case avgGradeValue = "avg_grade_value"
        case intelligenceTotalScore = "intelligence_total_score"
        case hasData = "has_data"
    }
}
