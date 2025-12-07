//
//  MainTabView.swift
//  Haupt-TabView mit neuem Solo Leveling Design
//  Behält ALLE Ihre Funktionen: Auth, Artifacts, Profile, etc.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    init() {
        // Neues Shadow Theme anwenden
        ShadowTheme.applyGlobalTheme()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home mit Artifacts
            HomeView()
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Status Window (Leveling System)
            StatusWindowView()
                .tag(1)
                .tabItem {
                    Label("Status", systemImage: "chart.bar.fill")
                }
            
            // Leaderboard oder Quest Log
            LeaderboardView()
                .tag(2)
                .tabItem {
                    Label("Ranks", systemImage: "list.number")
                }
            
            // Profile
            ProfileViewWrapper()
                .tag(3)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(Color.violetGlow)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
