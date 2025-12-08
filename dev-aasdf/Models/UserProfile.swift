//
//  UserProfile.swift
//  dev-aasdf
//

import Foundation

public struct UserProfile: Codable, Identifiable {
    public let id: String
    public let username: String
    public let profilePicUrl: String?
    public let createdAt: String
    public let isActive: Bool
    public let walletAddress: String

    // Computed property for Identifiable
    public var userId: String { id }

    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username
        case profilePicUrl = "profile_pic_url"
        case createdAt = "created_at"
        case isActive = "is_active"
        case walletAddress = "wallet_address"
    }

    public init(
        id: String, username: String, profilePicUrl: String?, createdAt: String, isActive: Bool,
        walletAddress: String
    ) {
        self.id = id
        self.username = username
        self.profilePicUrl = profilePicUrl
        self.createdAt = createdAt
        self.isActive = isActive
        self.walletAddress = walletAddress
    }

    // Helper for date formatting
    public var formattedJoinDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .none
            displayFormatter.locale = Locale(identifier: "de_DE")
            return displayFormatter.string(from: date)
        }
        return createdAt
    }
}

public struct UpdateUsernameRequest: Codable {
    public let username: String

    public init(username: String) {
        self.username = username
    }
}
