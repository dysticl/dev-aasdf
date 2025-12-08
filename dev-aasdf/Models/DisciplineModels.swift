//
//  DisciplineModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import Foundation

public struct TodayDisciplineResponse: Codable {
    public let scoreDate: String
    public let disciplineDailyScore: Double?
    public let disciplineConsistencyPct: Double?
    public let disciplineTotalScore: Double?
    public let hasData: Bool

    enum CodingKeys: String, CodingKey {
        case scoreDate = "score_date"
        case disciplineDailyScore = "discipline_daily_score"
        case disciplineConsistencyPct = "discipline_consistency_pct"
        case disciplineTotalScore = "discipline_total_score"
        case hasData = "has_data"
    }

    public init(
        scoreDate: String, disciplineDailyScore: Double?, disciplineConsistencyPct: Double?,
        disciplineTotalScore: Double?, hasData: Bool
    ) {
        self.scoreDate = scoreDate
        self.disciplineDailyScore = disciplineDailyScore
        self.disciplineConsistencyPct = disciplineConsistencyPct
        self.disciplineTotalScore = disciplineTotalScore
        self.hasData = hasData
    }
}
