//
//  NewContentView.swift
//  Root view with Liquid Glass TabView - NEW REDESIGN
//

import SwiftUI

struct NewContentView: View {
    @State private var appData = AppData()
    @State private var selectedTab = 0
    
    init() {
        ShadowTheme.applyGlobalTheme()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NewHomeView()
                .tag(0)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            NewStreakView()
                .tag(1)
                .tabItem {
                    Label("Streak", systemImage: "flame.fill")
                }
            
            NewAddTaskView()
                .tag(2)
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            
            NewProfileView()
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
    NewContentView()
}
