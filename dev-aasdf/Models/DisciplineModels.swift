//
//  DisciplineModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 05.12.25.
//

import Foundation

struct TodayDisciplineResponse: Codable {
    let scoreDate: String
    let disciplineDailyScore: Double?
    let disciplineConsistencyPct: Double?
    let disciplineTotalScore: Double?
    let hasData: Bool

    enum CodingKeys: String, CodingKey {
        case scoreDate = "score_date"
        case disciplineDailyScore = "discipline_daily_score"
        case disciplineConsistencyPct = "discipline_consistency_pct"
        case disciplineTotalScore = "discipline_total_score"
        case hasData = "has_data"
    }
}
