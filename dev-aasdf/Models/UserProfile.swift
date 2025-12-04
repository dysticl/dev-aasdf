//
//  UserProfile.swift
//  dev-aasdf
//

import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String
    let username: String
    let profilePicUrl: String?
    let createdAt: String
    let isActive: Bool
    let walletAddress: String
    
    // Computed property for Identifiable
    var userId: String { id }
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username
        case profilePicUrl = "profile_pic_url"
        case createdAt = "created_at"
        case isActive = "is_active"
        case walletAddress = "wallet_address"
    }
    
    // Helper for date formatting
    var formattedJoinDate: String {
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

struct UpdateUsernameRequest: Codable {
    let username: String
}
