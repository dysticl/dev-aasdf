//
//  ProfileView.swift
//  Level + XP ring at top, spacious glass cards, achievements below
//

import SwiftUI

struct ProfileOverviewView: View {
    @Environment(AppData.self) private var appData
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.shadowBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Level + XP Ring
                        levelSection
                        
                        // Member Since & Wallet Address Cards
                        infoCardsSection
                        
                        // Achievements
                        achievementsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
        }
    }
    
    // MARK: - Level Section
    
    private var levelSection: some View {
        VStack(spacing: 20) {
            // Circular XP Ring
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: appData.xpProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.violetGlow, .violetGlow.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .violetGlow()
                
                // Level display
                VStack(spacing: 4) {
                    Text("LV.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.shadowTextSecondary)
                    
                    Text("\(appData.level)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.shadowText)
                }
            }
            
            // XP percentage
            Text("\(Int(appData.xpProgress * 100))% to next level")
                .font(.subheadline)
                .foregroundStyle(Color.shadowTextSecondary)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Info Cards Section
    
    private var infoCardsSection: some View {
        VStack(spacing: 16) {
            // Member Since Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundStyle(.violetGlow)
                    
                    Text("Member Since")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.shadowTextSecondary)
                }
                
                Text(appData.memberSince)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.shadowText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .liquidGlass(cornerRadius: 20)
            
            // Wallet Address Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "wallet.pass")
                        .font(.title2)
                        .foregroundStyle(.violetGlow)
                    
                    Text("Wallet Address")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.shadowTextSecondary)
                }
                
                HStack {
                    Text(appData.walletAddress)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(Color.shadowText)
                    
                    Spacer()
                    
                    Button {
                        // Copy to clipboard
                        UIPasteboard.general.string = appData.walletAddress
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.title3)
                            .foregroundStyle(.violetGlow)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .liquidGlass(cornerRadius: 20)
        }
    }
    
    // MARK: - Achievements Section
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ACHIEVEMENTS")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.shadowTextSecondary)
                .tracking(2)
            
            VStack(spacing: 12) {
                AchievementRow(
                    icon: "flame.fill",
                    title: "First Streak",
                    description: "Complete 7 days in a row",
                    isUnlocked: true
                )
                
                AchievementRow(
                    icon: "star.fill",
                    title: "Rising Hunter",
                    description: "Reach Level 10",
                    isUnlocked: true
                )
                
                AchievementRow(
                    icon: "bolt.fill",
                    title: "Shadow Monarch",
                    description: "Reach Level 50",
                    isUnlocked: false
                )
                
                AchievementRow(
                    icon: "crown.fill",
                    title: "S-Rank",
                    description: "Complete 100 quests",
                    isUnlocked: false
                )
            }
        }
    }
}

// MARK: - Achievement Row Component

struct AchievementRow: View {
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.violetGlow.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? Color.violetGlow : Color.shadowTextSecondary)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isUnlocked ? Color.shadowText : Color.shadowTextSecondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.shadowTextSecondary)
            }
            
            Spacer()
            
            // Lock indicator
            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(Color.shadowTextSecondary)
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 16)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    ProfileOverviewView()
        .environment(AppData())
}
