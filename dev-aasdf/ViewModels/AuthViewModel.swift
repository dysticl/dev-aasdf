//
//  AuthViewModel.swift
//  dev-aasdf
//

import Foundation
import SwiftUI
import os.log

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var currentUser: UserData?
    @Published var showWelcomeToast = false
    @Published var welcomeMessage = ""
    
    // MARK: - Private Properties
    private let apiService = APIService.shared
    private let logger = Logger(subsystem: "com.aasdf.app", category: "AuthViewModel")
    private var pendingNonce: String?
    private var pendingWalletAddress: String?
    private let network = "devnet" // Change to "mainnet" for production
    
    // MARK: - Public Methods
    
    /// Check for existing session on app launch
    func checkExistingSession() async {
        guard KeychainHelper.shared.getToken() != nil else {
            logger.info("No existing session found")
            return
        }
        
        do {
            let user = try await apiService.getCurrentUser()
            self.currentUser = user
            self.isAuthenticated = true
            logger.info("Restored session for user: \(user.username)")
        } catch {
            logger.error("Session invalid, clearing token: \(error.localizedDescription)")
            KeychainHelper.shared.deleteToken()
        }
    }
    
    /// Initiate Phantom wallet connection
    func connectPhantomWallet() async {
        guard isPhantomInstalled() else {
            showErrorAlert("Phantom wallet not installed. Please install Phantom from the App Store.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // For deeplink flow, we'll request nonce after getting wallet address from Phantom
            // First, open Phantom to connect
            openPhantomConnect()
        } catch {
            logger.error("Failed to initiate connection: \(error.localizedDescription)")
            showErrorAlert(error.localizedDescription)
            isLoading = false
        }
    }
    
    /// Handle deeplink callback from Phantom
    func handleDeeplink(url: URL) {
        logger.info("Received deeplink: \(url.absoluteString)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else {
            logger.error("Invalid deeplink format")
            return
        }
        
        switch host {
        case "onConnect":
            handleConnectCallback(components: components)
        case "onSignMessage":
            handleSignMessageCallback(components: components)
        case "onDisconnect":
            logout()
        default:
            logger.warning("Unknown deeplink host: \(host)")
        }
    }
    
    /// Logout and clear session
    func logout() {
        KeychainHelper.shared.deleteToken()
        currentUser = nil
        isAuthenticated = false
        pendingNonce = nil
        pendingWalletAddress = nil
        logger.info("User logged out")
    }
    
    // MARK: - Private Methods
    
    private func isPhantomInstalled() -> Bool {
        guard let url = URL(string: "phantom://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func openPhantomConnect() {
        let appURL = "aasdf"
        let cluster = network
        
        var components = URLComponents()
        components.scheme = "phantom"
        components.host = "v1"
        components.path = "/connect"
        components.queryItems = [
            URLQueryItem(name: "app_url", value: "https://aasdf.app"),
            URLQueryItem(name: "dapp_encryption_public_key", value: ""), // Not needed for basic flow
            URLQueryItem(name: "cluster", value: cluster),
            URLQueryItem(name: "redirect_link", value: "\(appURL)://onConnect")
        ]
        
        guard let url = components.url else {
            showErrorAlert("Failed to create Phantom URL")
            isLoading = false
            return
        }
        
        logger.info("Opening Phantom for connection: \(url.absoluteString)")
        UIApplication.shared.open(url)
    }
    
    private func handleConnectCallback(components: URLComponents) {
        guard let params = components.queryItems else {
            showErrorAlert("Invalid connect callback")
            isLoading = false
            return
        }
        
        // Check for error
        if let errorCode = params.first(where: { $0.name == "errorCode" })?.value {
            let errorMsg = params.first(where: { $0.name == "errorMessage" })?.value ?? "Connection failed"
            logger.error("Phantom connect error: \(errorCode) - \(errorMsg)")
            showErrorAlert(errorMsg)
            isLoading = false
            return
        }
        
        // Get public key (wallet address)
        guard let publicKey = params.first(where: { $0.name == "phantom_encryption_public_key" })?.value else {
            // Try alternative parameter name
            if let pubKey = params.first(where: { $0.name == "public_key" })?.value {
                pendingWalletAddress = pubKey
            } else {
                showErrorAlert("No wallet address returned")
                isLoading = false
                return
            }
            return
        }
        
        pendingWalletAddress = publicKey
        logger.info("Connected wallet: \(publicKey)")
        
        // Now request nonce from backend and prompt for signature
        Task {
            await requestNonceAndSign()
        }
    }
    
    private func requestNonceAndSign() async {
        guard let walletAddress = pendingWalletAddress else {
            showErrorAlert("No wallet address available")
            isLoading = false
            return
        }
        
        do {
            let nonceResponse = try await apiService.requestNonce(walletAddress: walletAddress, network: network)
            pendingNonce = nonceResponse.nonce
            
            logger.info("Received nonce, requesting signature")
            
            // Open Phantom to sign the message
            openPhantomSignMessage(message: nonceResponse.message)
            
        } catch {
            logger.error("Failed to get nonce: \(error.localizedDescription)")
            showErrorAlert("Failed to initiate login: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    private func openPhantomSignMessage(message: String) {
        let appURL = "aasdf"
        
        // Base64 encode the message
        guard let messageData = message.data(using: .utf8) else {
            showErrorAlert("Failed to encode message")
            isLoading = false
            return
        }
        let base64Message = messageData.base64EncodedString()
        
        var components = URLComponents()
        components.scheme = "phantom"
        components.host = "v1"
        components.path = "/signMessage"
        components.queryItems = [
            URLQueryItem(name: "message", value: base64Message),
            URLQueryItem(name: "cluster", value: network),
            URLQueryItem(name: "redirect_link", value: "\(appURL)://onSignMessage"),
            URLQueryItem(name: "display", value: "utf8")
        ]
        
        guard let url = components.url else {
            showErrorAlert("Failed to create sign URL")
            isLoading = false
            return
        }
        
        logger.info("Opening Phantom for signing")
        UIApplication.shared.open(url)
    }
    
    private func handleSignMessageCallback(components: URLComponents) {
        guard let params = components.queryItems else {
            showErrorAlert("Invalid sign callback")
            isLoading = false
            return
        }
        
        // Check for error
        if let errorCode = params.first(where: { $0.name == "errorCode" })?.value {
            let errorMsg = params.first(where: { $0.name == "errorMessage" })?.value ?? "Signing failed"
            logger.error("Phantom sign error: \(errorCode) - \(errorMsg)")
            showErrorAlert(errorMsg)
            isLoading = false
            return
        }
        
        // Get signature (base58 encoded)
        guard let signature = params.first(where: { $0.name == "signature" })?.value else {
            showErrorAlert("No signature returned")
            isLoading = false
            return
        }
        
        logger.info("Received signature, verifying with backend")
        
        Task {
            await verifySignature(signature: signature)
        }
    }
    
    private func verifySignature(signature: String) async {
        guard let walletAddress = pendingWalletAddress,
              let nonce = pendingNonce else {
            showErrorAlert("Missing authentication data")
            isLoading = false
            return
        }
        
        do {
            let response = try await apiService.verifySignature(
                walletAddress: walletAddress,
                signature: signature,
                nonce: nonce,
                network: network
            )
            
            // Store JWT securely
            KeychainHelper.shared.saveToken(response.accessToken)
            
            // Fetch user data
            let user = try await apiService.getCurrentUser()
            self.currentUser = user
            self.isAuthenticated = true
            
            // Show welcome message
            let welcomeText = response.isNewUser
                ? "Welcome, new Hunter! Balance: \(String(format: "%.4f", response.balanceSol)) SOL"
                : "Welcome back! Balance: \(String(format: "%.4f", response.balanceSol)) SOL"
            showWelcome(message: welcomeText)
            
            logger.info("Authentication successful for user: \(response.userId)")
            
        } catch let error as APIError {
            logger.error("Verification failed: \(error.localizedDescription)")
            showErrorAlert(error.message)
        } catch {
            logger.error("Verification failed: \(error.localizedDescription)")
            showErrorAlert("Authentication failed: \(error.localizedDescription)")
        }
        
        isLoading = false
        pendingNonce = nil
        pendingWalletAddress = nil
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func showWelcome(message: String) {
        welcomeMessage = message
        showWelcomeToast = true
        
        // Auto-hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showWelcomeToast = false
        }
    }
}
