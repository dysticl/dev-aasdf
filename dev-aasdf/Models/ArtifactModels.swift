//
//  ArtifactModels.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 06.12.25.
//

import Foundation

// MARK: - Categories

public struct ArtifactCategory: Codable, Identifiable, Hashable {
    public let categoryId: String
    public let name: String
    public let description: String
    public let iconUrl: String

    public var id: String { categoryId }

    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case name, description
        case iconUrl = "icon_url"
    }

    public init(categoryId: String, name: String, description: String, iconUrl: String) {
        self.categoryId = categoryId
        self.name = name
        self.description = description
        self.iconUrl = iconUrl
    }
}

public struct ArtifactDeadlineResponse: Codable {
    public let deadline: String?
    public let now: String
    public let remainingSeconds: Double?
    public let isOverdue: Bool

    enum CodingKeys: String, CodingKey {
        case deadline, now
        case remainingSeconds = "remaining_seconds"
        case isOverdue = "is_overdue"
    }
}

public struct CategoriesResponse: Codable {
    public let categories: [ArtifactCategory]

    public init(categories: [ArtifactCategory]) {
        self.categories = categories
    }
}

// MARK: - AI Estimate

public struct LifeDimensions: Codable, Hashable {
    public let health: Double
    public let discipline: Double
    public let intelligence: Double
    public let strength: Double

    public init(health: Double, discipline: Double, intelligence: Double, strength: Double) {
        self.health = health
        self.discipline = discipline
        self.intelligence = intelligence
        self.strength = strength
    }
}

public struct AIEstimate: Codable, Hashable {
    public let estimatedXp: Int
    public let estimatedHours: Double
    public let lifeImpactScore: Double
    public let dopaminCost: Double
    public let lifeDimensions: LifeDimensions
    public let difficulty: Double
    public let reasoning: String

    enum CodingKeys: String, CodingKey {
        case estimatedXp = "estimated_xp"
        case estimatedHours = "estimated_hours"
        case lifeImpactScore = "life_impact_score"
        case dopaminCost = "dopamin_cost"
        case lifeDimensions = "life_dimensions"
        case difficulty, reasoning
    }

    public init(
        estimatedXp: Int, estimatedHours: Double, lifeImpactScore: Double, dopaminCost: Double,
        lifeDimensions: LifeDimensions, difficulty: Double, reasoning: String
    ) {
        self.estimatedXp = estimatedXp
        self.estimatedHours = estimatedHours
        self.lifeImpactScore = lifeImpactScore
        self.dopaminCost = dopaminCost
        self.lifeDimensions = lifeDimensions
        self.difficulty = difficulty
        self.reasoning = reasoning
    }
}

// MARK: - Artifact (List Item)

public struct Artifact: Codable, Identifiable, Hashable {
    public let artifactId: String
    public let taskName: String
    public let description: String?
    public let category: String
    public let status: String
    public let priority: String?
    public let deadline: String?
    public let aiEstimate: AIEstimate?
    public let createdAt: String
    public let updatedAt: String?
    public let completedAt: String?

    public var id: String { artifactId }

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case taskName = "task_name"
        case description, category, status, priority, deadline
        case aiEstimate = "ai_estimate"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }

    public init(
        artifactId: String, taskName: String, description: String?, category: String,
        status: String, priority: String?, deadline: String?, aiEstimate: AIEstimate?,
        createdAt: String, updatedAt: String?, completedAt: String?
    ) {
        self.artifactId = artifactId
        self.taskName = taskName
        self.description = description
        self.category = category
        self.status = status
        self.priority = priority
        self.deadline = deadline
        self.aiEstimate = aiEstimate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }
}

public struct ArtifactsListResponse: Codable {
    public let artifacts: [Artifact]
    public let total: Int
    public let page: Int?
    public let perPage: Int?

    enum CodingKeys: String, CodingKey {
        case artifacts, total, page
        case perPage = "per_page"
    }

    public init(artifacts: [Artifact], total: Int, page: Int?, perPage: Int?) {
        self.artifacts = artifacts
        self.total = total
        self.page = page
        self.perPage = perPage
    }
}

// MARK: - Artifact Detail

public struct CompletionData: Codable, Hashable {
    public let actualHours: Double
    public let xpAwarded: Int
    public let completedAt: String

    enum CodingKeys: String, CodingKey {
        case actualHours = "actual_hours"
        case xpAwarded = "xp_awarded"
        case completedAt = "completed_at"
    }

    public init(actualHours: Double, xpAwarded: Int, completedAt: String) {
        self.actualHours = actualHours
        self.xpAwarded = xpAwarded
        self.completedAt = completedAt
    }
}

public struct QualityFactors: Codable, Hashable {
    public let thoroughness: Double
    public let presentation: Double
    public let effortRatio: Double

    enum CodingKeys: String, CodingKey {
        case thoroughness, presentation
        case effortRatio = "effort_ratio"
    }

    public init(thoroughness: Double, presentation: Double, effortRatio: Double) {
        self.thoroughness = thoroughness
        self.presentation = presentation
        self.effortRatio = effortRatio
    }
}

public struct ValidationData: Codable, Hashable {
    public let isValid: Bool
    public let confidence: Double
    public let executionQuality: Double
    public let qualityFactors: QualityFactors
    public let feedback: String
    public let warnings: [String]

    enum CodingKeys: String, CodingKey {
        case isValid = "is_valid"
        case confidence
        case executionQuality = "execution_quality"
        case qualityFactors = "quality_factors"
        case feedback, warnings
    }

    public init(
        isValid: Bool, confidence: Double, executionQuality: Double, qualityFactors: QualityFactors,
        feedback: String, warnings: [String]
    ) {
        self.isValid = isValid
        self.confidence = confidence
        self.executionQuality = executionQuality
        self.qualityFactors = qualityFactors
        self.feedback = feedback
        self.warnings = warnings
    }
}

public struct Proof: Codable, Identifiable, Hashable {
    public let proofId: String
    public let filename: String?
    public let size: Int?
    public let mimeType: String
    public let downloadUrl: String
    public let uploadedAt: String?

    public var id: String { proofId }

    enum CodingKeys: String, CodingKey {
        case proofId = "proof_id"
        case filename, size
        case mimeType = "mime_type"
        case downloadUrl = "download_url"
        case uploadedAt = "uploaded_at"
    }

    public init(
        proofId: String, filename: String?, size: Int?, mimeType: String, downloadUrl: String,
        uploadedAt: String?
    ) {
        self.proofId = proofId
        self.filename = filename
        self.size = size
        self.mimeType = mimeType
        self.downloadUrl = downloadUrl
        self.uploadedAt = uploadedAt
    }
}

public struct ArtifactDetail: Codable {
    public let artifactId: String
    public let taskName: String
    public let description: String?
    public let category: String
    public let status: String
    public let priority: String?
    public let deadline: String?
    public let aiEstimate: AIEstimate?
    public let completion: CompletionData?
    public let validation: ValidationData?
    public let proofs: [Proof]
    public let createdAt: String
    public let updatedAt: String?
    public let completedAt: String?

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

    public init(
        artifactId: String, taskName: String, description: String?, category: String,
        status: String, priority: String?, deadline: String?, aiEstimate: AIEstimate?,
        completion: CompletionData?, validation: ValidationData?, proofs: [Proof],
        createdAt: String, updatedAt: String?, completedAt: String?
    ) {
        self.artifactId = artifactId
        self.taskName = taskName
        self.description = description
        self.category = category
        self.status = status
        self.priority = priority
        self.deadline = deadline
        self.aiEstimate = aiEstimate
        self.completion = completion
        self.validation = validation
        self.proofs = proofs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }
}

// MARK: - API Requests & Responses

public struct CreateArtifactRequest: Codable {
    public let taskName: String
    public let description: String?
    public let category: String
    public let estimatedHours: Double
    public let priority: String?
    public let deadline: String?

    enum CodingKeys: String, CodingKey {
        case taskName = "task_name"
        case description, category
        case estimatedHours = "estimated_hours"
        case priority, deadline
    }

    public init(
        taskName: String, description: String?, category: String, estimatedHours: Double,
        priority: String?, deadline: String?
    ) {
        self.taskName = taskName
        self.description = description
        self.category = category
        self.estimatedHours = estimatedHours
        self.priority = priority
        self.deadline = deadline
    }
}

public struct CreateArtifactResponse: Codable {
    public let artifactId: String
    public let taskName: String
    public let status: String
    public let aiEstimate: AIEstimate
    public let createdAt: String

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case taskName = "task_name"
        case status
        case aiEstimate = "ai_estimate"
        case createdAt = "created_at"
    }

    public init(
        artifactId: String, taskName: String, status: String, aiEstimate: AIEstimate,
        createdAt: String
    ) {
        self.artifactId = artifactId
        self.taskName = taskName
        self.status = status
        self.aiEstimate = aiEstimate
        self.createdAt = createdAt
    }
}

public struct StartArtifactResponse: Codable {
    public let artifactId: String
    public let status: String
    public let message: String

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case status, message
    }

    public init(artifactId: String, status: String, message: String) {
        self.artifactId = artifactId
        self.status = status
        self.message = message
    }
}

public struct UploadProofResponse: Codable {
    public let artifactId: String
    public let proofsUploaded: Int
    public let proofs: [Proof]
    public let actualHours: Double
    public let status: String

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case proofsUploaded = "proofs_uploaded"
        case proofs
        case actualHours = "actual_hours"
        case status
    }

    public init(
        artifactId: String, proofsUploaded: Int, proofs: [Proof], actualHours: Double,
        status: String
    ) {
        self.artifactId = artifactId
        self.proofsUploaded = proofsUploaded
        self.proofs = proofs
        self.actualHours = actualHours
        self.status = status
    }
}

public struct CompleteArtifactRequest: Codable {
    public let actualHours: Double
    public let userNote: String?

    enum CodingKeys: String, CodingKey {
        case actualHours = "actual_hours"
        case userNote = "user_note"
    }

    public init(actualHours: Double, userNote: String?) {
        self.actualHours = actualHours
        self.userNote = userNote
    }
}

public struct XPBreakdown: Codable, Hashable {
    public let lifeImpactXp: Double
    public let dopaminXp: Double
    public let xpRaw: Double
    public let executionQuality: Double
    public let timeMultiplier: Double
    public let xpQuality: Double
    public let xpFinal: Int

    enum CodingKeys: String, CodingKey {
        case lifeImpactXp = "life_impact_xp"
        case dopaminXp = "dopamin_xp"
        case xpRaw = "xp_raw"
        case executionQuality = "execution_quality"
        case timeMultiplier = "time_multiplier"
        case xpQuality = "xp_quality"
        case xpFinal = "xp_final"
    }

    public init(
        lifeImpactXp: Double, dopaminXp: Double, xpRaw: Double, executionQuality: Double,
        timeMultiplier: Double, xpQuality: Double, xpFinal: Int
    ) {
        self.lifeImpactXp = lifeImpactXp
        self.dopaminXp = dopaminXp
        self.xpRaw = xpRaw
        self.executionQuality = executionQuality
        self.timeMultiplier = timeMultiplier
        self.xpQuality = xpQuality
        self.xpFinal = xpFinal
    }
}

public struct CompletionResponse: Codable {
    public let artifactId: String
    public let status: String
    public let xpAwarded: Int?  // Optional - only when accepted
    public let breakdown: XPBreakdown?  // Optional - only when accepted
    public let feedback: String?  // Optional - might be missing
    public let completedAt: String?  // Optional - only when accepted
    public let leveledUp: Bool?  // Optional - only when accepted
    public let newLevel: Int?
    public let warnings: [String]?  // Present when rejected

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case status
        case xpAwarded = "xp_awarded"
        case breakdown, feedback
        case completedAt = "completed_at"
        case leveledUp = "leveled_up"
        case newLevel = "new_level"
        case warnings
    }

    public init(
        artifactId: String, status: String, xpAwarded: Int?, breakdown: XPBreakdown?,
        feedback: String?, completedAt: String?, leveledUp: Bool?, newLevel: Int?,
        warnings: [String]?
    ) {
        self.artifactId = artifactId
        self.status = status
        self.xpAwarded = xpAwarded
        self.breakdown = breakdown
        self.feedback = feedback
        self.completedAt = completedAt
        self.leveledUp = leveledUp
        self.newLevel = newLevel
        self.warnings = warnings
    }
}

public struct CancelArtifactResponse: Codable {
    public let artifactId: String
    public let status: String
    public let message: String

    enum CodingKeys: String, CodingKey {
        case artifactId = "artifact_id"
        case status, message
    }

    public init(artifactId: String, status: String, message: String) {
        self.artifactId = artifactId
        self.status = status
        self.message = message
    }
}
