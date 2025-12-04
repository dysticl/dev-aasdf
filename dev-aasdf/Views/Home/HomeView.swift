//
//  HomeView.swift
//  dev-aasdf
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Ambient Glow
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .blur(radius: 100)
                    .offset(x: -100, y: -200)
                
                // Main Content
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Willkommen, Hunter.")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Grind your stats.")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                
                // Bottom Navigation Bar (Liquid Glass)
                VStack {
                    Spacer()
                    
                    HStack {
                        NavigationLink(destination: ProfileView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                Text("Profile")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Material.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        Spacer()
                        
                        // Placeholder for future actions
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.trailing, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .frame(height: 80)
                    .background(
                        Rectangle()
                            .fill(Material.ultraThinMaterial)
                            .mask(
                                LinearGradient(
                                    colors: [.black.opacity(1), .black.opacity(0)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                    )
                }
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
