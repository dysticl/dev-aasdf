//
//  LoginView.swift
//  dev-aasdf
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Logo and Title
                VStack(spacing: 16) {
                    // Liquid Glass effect logo
                    ZStack {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 100, height: 100)
                            .glassEffect(.regular.interactive(), in: .circle)

                        Image(systemName: "flame.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(LinearGradient(colors: [.white, AppTheme.accent], startPoint: .top, endPoint: .bottom))
                    }
                    .shadow(color: AppTheme.accent.opacity(0.4), radius: 20)
                    
                    Text("AASDF")
                        .font(.system(size: 42, weight: .black, design: .default))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 8)
                    
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
                        .foregroundColor(AppTheme.accent)
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
                    }
                    .buttonStyle(.glassProminent)
                    .tint(AppTheme.accent)
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                    .glassEffect(.regular, in: .capsule)
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
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.clear)
                            .glassEffect(.regular.tint(AppTheme.accentSecondary).interactive(), in: .rect(cornerRadius: 12))
                    )
                    .shadow(radius: 10)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: authViewModel.showWelcomeToast)
            }
        }
        .appChrome()
        .appBackground()
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
        .appChrome()
        .appBackground()
}
