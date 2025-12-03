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
                MainView()
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
    }
}

// Placeholder for main app view after login
struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Welcome, Hunter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let user = authViewModel.currentUser {
                    Text("Wallet: \(String(user.wallet.address.prefix(8)))...")
                        .foregroundColor(.gray)
                    
                    Text("Balance: \(String(format: "%.4f", user.wallet.balanceSol)) SOL")
                        .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                        .font(.headline)
                }
                
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Disconnect Wallet")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.3))
                        .cornerRadius(10)
                }
                .padding(.top, 40)
            }
        }
    }
}

#Preview {
    ContentView()
}
