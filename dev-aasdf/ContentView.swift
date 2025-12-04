//
//  ContentView.swift
//  dev-aasdf
//
//  Created by Daniel Kasanzew on 03.12.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                HomeView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
        .onOpenURL { url in
            authViewModel.handleDeeplink(url: url)
        }
        .task {
            await authViewModel.checkExistingSession()
        }
        // Global dark mode enforcement
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
