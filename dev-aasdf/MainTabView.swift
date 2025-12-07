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
        // Custom init if needed
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

            // Profile
            ProfileView()
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
