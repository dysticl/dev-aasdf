//
//  StrengthModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import Foundation

public struct TodayStrengthResponse: Codable {
    public let scoreDate: String
    public let strengthKraftScore: Double
    public let strengthCardioScore: Double
    public let strengthTotalScore: Double
    public let hasData: Bool

    enum CodingKeys: String, CodingKey {
        case scoreDate = "score_date"
        case strengthKraftScore = "strength_kraft_score"
        case strengthCardioScore = "strength_cardio_score"
        case strengthTotalScore = "strength_total_score"
        case hasData = "has_data"
    }

    public init(
        scoreDate: String, strengthKraftScore: Double, strengthCardioScore: Double,
        strengthTotalScore: Double, hasData: Bool
    ) {
        self.scoreDate = scoreDate
        self.strengthKraftScore = strengthKraftScore
        self.strengthCardioScore = strengthCardioScore
        self.strengthTotalScore = strengthTotalScore
        self.hasData = hasData
    }
}
