//
//  ArtifactModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 06.12.25.
//

import Foundation

// MARK: - Categories

struct ArtifactCategory: Codable, Identifiable, Hashable {
    let categoryId: String
    let name: String
    let description: String
    let iconUrl: String

    var id: String { categoryId }

    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case name, description
        case iconUrl = "icon_url"
    }
}

struct CategoriesResponse: Codable {
    let categories: [ArtifactCategory]
}

// MARK: - AI Estimate

struct LifeDimensions: Codable, Hashable {
    let health: Double
    let discipline: Double
    let intelligence: Double
    let strength: Double
}

struct AIEstimate: Codable, Hashable {
    let estimatedXp: Int
    let estimatedHours: Double
    let lifeImpactScore: Double
    let dopaminCost: Double
    let lifeDimensions: LifeDimensions
    let difficulty: Double
    let reasoning: String

    enum CodingKeys: String, CodingKey {
        case estimatedXp = "estimated_xp"
        case estimatedHours = "estimated_hours"
        case lifeImpactScore = "life_impact_score"
        case dopaminCost = "dopamin_cost"
        case lifeDimensions = "life_dimensions"
        case difficulty, reasoning
    }
}

// MARK: - Artifact (List Item)

struct Artifact: Codable, Identifiable, Hashable {
    let artifactId: String
    let taskName: String
    let description: String?
    let category: String
    let status: String
    let priority: String?
    let deadline: String?
    let aiEstimate: AIEstimate?
    let createdAt: String
    let updatedAt: String?
    let completedAt: String?

    var id: String { artifactId }

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case taskName = "task_name"
        case description, category, status, priority, deadline
        case aiEstimate = "ai_estimate"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }
}

struct ArtifactsListResponse: Codable {
    let items: [Artifact]
    let total: Int
    let limit: Int
    let offset: Int
}

// MARK: - Artifact Detail

struct CompletionData: Codable, Hashable {
    let actualHours: Double
    let xpAwarded: Int
    let completedAt: String

    enum CodingKeys: String, CodingKey {
        case actualHours = "actual_hours"
        case xpAwarded = "xp_awarded"
        case completedAt = "completed_at"
    }
}

struct QualityFactors: Codable, Hashable {
    let thoroughness: Double
    let presentation: Double
    let effortRatio: Double

    enum CodingKeys: String, CodingKey {
        case thoroughness, presentation
        case effortRatio = "effort_ratio"
    }
}

struct ValidationData: Codable, Hashable {
    let isValid: Bool
    let confidence: Double
    let executionQuality: Double
    let qualityFactors: QualityFactors
    let feedback: String
    let warnings: [String]

    enum CodingKeys: String, CodingKey {
        case isValid = "is_valid"
        case confidence
        case executionQuality = "execution_quality"
        case qualityFactors = "quality_factors"
        case feedback, warnings
    }
}

struct Proof: Codable, Identifiable, Hashable {
    let proofId: String
    let filename: String?
    let size: Int?
    let mimeType: String
    let downloadUrl: String
    let uploadedAt: String?

    var id: String { proofId }

    enum CodingKeys: String, CodingKey {
        case proofId = "proof_id"
        case filename, size
        case mimeType = "mime_type"
        case downloadUrl = "download_url"
        case uploadedAt = "uploaded_at"
    }
}

struct ArtifactDetail: Codable {
    let artifactId: String
    let taskName: String
    let description: String?
    let category: String
    let status: String
    let priority: String?
    let deadline: String?
    let aiEstimate: AIEstimate?
    let completion: CompletionData?
    let validation: ValidationData?
    let proofs: [Proof]
    let createdAt: String
    let updatedAt: String?
    let completedAt: String?

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case taskName = "task_name"
        case description, category, status, priority, deadline
        case aiEstimate = "ai_estimate"
        case completion, validation, proofs
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }
}

// MARK: - API Requests & Responses

struct CreateArtifactRequest: Codable {
    let taskName: String
    let description: String?
    let category: String
    let estimatedHours: Double
    let priority: String?
    let deadline: String?

    enum CodingKeys: String, CodingKey {
        case taskName = "task_name"
        case description, category
        case estimatedHours = "estimated_hours"
        case priority, deadline
    }
}

struct CreateArtifactResponse: Codable {
    let artifactId: String
    let taskName: String
    let status: String
    let aiEstimate: AIEstimate
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case taskName = "task_name"
        case status
        case aiEstimate = "ai_estimate"
        case createdAt = "created_at"
    }
}

struct StartArtifactResponse: Codable {
    let artifactId: String
    let status: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case status, message
    }
}

struct UploadProofResponse: Codable {
    let artifactId: String
    let proofsUploaded: Int
    let proofs: [Proof]
    let actualHours: Double
    let status: String

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case proofsUploaded = "proofs_uploaded"
        case proofs
        case actualHours = "actual_hours"
        case status
    }
}

struct CompleteArtifactRequest: Codable {
    let actualHours: Double
    let userNote: String?

    enum CodingKeys: String, CodingKey {
        case actualHours = "actual_hours"
        case userNote = "user_note"
    }
}

struct XPBreakdown: Codable, Hashable {
    let lifeImpactXp: Double
    let dopaminXp: Double
    let xpRaw: Double
    let executionQuality: Double
    let timeMultiplier: Double
    let xpQuality: Double
    let xpFinal: Int

    enum CodingKeys: String, CodingKey {
        case lifeImpactXp = "life_impact_xp"
        case dopaminXp = "dopamin_xp"
        case xpRaw = "xp_raw"
        case executionQuality = "execution_quality"
        case timeMultiplier = "time_multiplier"
        case xpQuality = "xp_quality"
        case xpFinal = "xp_final"
    }
}

struct CompletionResponse: Codable {
    let artifactId: String
    let status: String
    let xpAwarded: Int
    let breakdown: XPBreakdown
    let feedback: String
    let completedAt: String
    let leveledUp: Bool
    let newLevel: Int?

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case status
        case xpAwarded = "xp_awarded"
        case breakdown, feedback
        case completedAt = "completed_at"
        case leveledUp = "leveled_up"
        case newLevel = "new_level"
    }
}

struct CancelArtifactResponse: Codable {
    let artifactId: String
    let status: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case status, message
    }
}
