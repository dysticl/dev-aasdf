//
//  ContentView.swift
//  Root view with Liquid Glass TabView
//

import SwiftUI

struct ContentView: View {
    @State private var appData = AppData()
    @State private var selectedTab = 0
    
    init() {
        ShadowTheme.applyGlobalTheme()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            StreakView()
                .tag(1)
                .tabItem {
                    Label("Streak", systemImage: "flame.fill")
                }
            
            AddTaskView()
                .tag(2)
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            
            ProfileView()
                .tag(3)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .environment(appData)
        .tint(.violetGlow)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
