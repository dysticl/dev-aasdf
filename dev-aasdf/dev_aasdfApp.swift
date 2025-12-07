//
//  dev_aasdfApp.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 03.12.25.
//

import SwiftUI

@main
struct dev_aasdfApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            // IHRE ORIGINALE APP mit neuem Design Theme
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
