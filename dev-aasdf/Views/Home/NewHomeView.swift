//
//  NewHomeView.swift
//  Minimalist home: streak bar + daily quote only - NEW REDESIGN
//

import SwiftUI

struct NewHomeView: View {
    @Environment(AppData.self) private var appData
    
    var body: some View {
        ZStack {
            // Background
            Color.shadowBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Centered daily quote
                VStack(spacing: 24) {
                    Text(appData.dailyQuote)
                        .font(.system(size: 28, weight: .medium, design: .serif))
                        .foregroundStyle(Color.shadowText)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.horizontal, 40)
                    
                    // Attribution
                    Text("— Sung Jin-Woo")
                        .font(.caption)
                        .foregroundStyle(Color.shadowTextSecondary)
                }
                
                Spacer()
                
                // Streak bar at bottom
                streakBar
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
            }
        }
    }
    
    private var streakBar: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                
                Text("Current Streak")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.shadowText)
                
                Spacer()
                
                Text("\(appData.streakDays) days")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.violetGlow)
                    .violetGlow()
            }
            
            // Streak progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    // Progress
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.violetGlow, .violetGlow.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * appData.streakProgress, height: 8)
                        .violetGlow()
                }
            }
            .frame(height: 8)
        }
        .padding(24)
        .liquidGlass(cornerRadius: 24)
    }
}

// MARK: - Streak View (separate tab)

struct NewStreakView: View {
    @Environment(AppData.self) private var appData
    
    var body: some View {
        ZStack {
            Color.shadowBackground
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Flame icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .violetGlow()
                
                // Streak count
                Text("\(appData.streakDays)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.shadowText)
                
                Text("Day Streak")
                    .font(.title3)
                    .foregroundStyle(Color.shadowTextSecondary)
                
                // Progress to next milestone
                VStack(spacing: 12) {
                    Text("Next milestone: 30 days")
                        .font(.subheadline)
                        .foregroundStyle(Color.shadowTextSecondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 12)
                            
                            Capsule()
                                .fill(.violetGlow)
                                .frame(width: geometry.size.width * (Double(appData.streakDays) / 30.0), height: 12)
                                .violetGlow()
                        }
                    }
                    .frame(height: 12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .padding()
        }
    }
}

#Preview("Home") {
    NewHomeView()
        .environment(AppData())
}

#Preview("Streak") {
    NewStreakView()
        .environment(AppData())
}
