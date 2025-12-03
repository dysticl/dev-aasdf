//
//  LoginView.swift
//  dev-aasdf
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Solo Leveling inspired colors
    private let primaryRed = Color(red: 0.8, green: 0.1, blue: 0.1)
    private let darkRed = Color(red: 0.5, green: 0.05, blue: 0.05)
    private let accentGold = Color(red: 0.85, green: 0.65, blue: 0.2)
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.05, blue: 0.1),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Ambient glow effect
            Circle()
                .fill(primaryRed.opacity(0.15))
                .blur(radius: 100)
                .offset(y: -200)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo and Title
                VStack(spacing: 16) {
                    // System icon placeholder - replace with custom logo
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [primaryRed, darkRed],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [primaryRed, accentGold],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .shadow(color: primaryRed.opacity(0.5), radius: 20)
                    
                    Text("AASDF")
                        .font(.system(size: 42, weight: .black, design: .default))
                        .foregroundColor(.white)
                        .shadow(color: primaryRed.opacity(0.8), radius: 10)
                    
                    Text("Artificial Autonomous\nSelf-Discipline Framework")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Tagline
                VStack(spacing: 8) {
                    Text("LEVEL UP YOUR LIFE")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(accentGold)
                        .tracking(4)
                    
                    Text("Daily disciplines. Real rewards.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Connect Button
                VStack(spacing: 20) {
                    Button(action: {
                        Task {
                            await authViewModel.connectPhantomWallet()
                        }
                    }) {
                        HStack(spacing: 12) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "wallet.pass.fill")
                                    .font(.title3)
                            }
                            
                            Text(authViewModel.isLoading ? "Connecting..." : "Connect Phantom Wallet")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [primaryRed, darkRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: primaryRed.opacity(0.5), radius: 10, y: 5)
                    }
                    .disabled(authViewModel.isLoading)
                    .opacity(authViewModel.isLoading ? 0.7 : 1)
                    
                    // Info text
                    Text("Secure login via Solana blockchain")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Network indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Devnet")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
            
            // Welcome Toast
            if authViewModel.showWelcomeToast {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(authViewModel.welcomeMessage)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: authViewModel.showWelcomeToast)
            }
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK", role: .cancel) {}
            
            if authViewModel.errorMessage?.contains("not installed") == true {
                Button("Get Phantom") {
                    if let url = URL(string: "https://apps.apple.com/app/phantom-crypto-wallet/id1598432977") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        } message: {
            Text(authViewModel.errorMessage ?? "An unknown error occurred")
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
