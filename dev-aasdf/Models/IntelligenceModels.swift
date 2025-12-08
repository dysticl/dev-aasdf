//
//  IntelligenceModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import Foundation

public struct TodayIntelligenceResponse: Codable {
    public let scoreDate: String
    public let avgGradeValue: Double?
    public let intelligenceTotalScore: Double?
    public let hasData: Bool

    enum CodingKeys: String, CodingKey {
        case scoreDate = "score_date"
        case avgGradeValue = "avg_grade_value"
        case intelligenceTotalScore = "intelligence_total_score"
        case hasData = "has_data"
    }

    public init(
        scoreDate: String, avgGradeValue: Double?, intelligenceTotalScore: Double?, hasData: Bool
    ) {
        self.scoreDate = scoreDate
        self.avgGradeValue = avgGradeValue
        self.intelligenceTotalScore = intelligenceTotalScore
        self.hasData = hasData
    }
}
