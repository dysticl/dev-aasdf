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
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                        .environmentObject(authViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
            .onOpenURL { url in
                // CRITICAL: Handle deep links from Phantom wallet
                authViewModel.handleDeeplink(url: url)
            }
            .task {
                // Check for existing session on app launch
                await authViewModel.checkExistingSession()
            }
            .preferredColorScheme(.dark)
        }
    }
}
