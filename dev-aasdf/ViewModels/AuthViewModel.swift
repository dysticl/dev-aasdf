//
//  AuthViewModel.swift
//  dev-aasdf
//

import Foundation
import SwiftUI
import Combine
import class Sodium.Sodium // Explicit import to avoid shadowing warning
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
    
    // Sodium for XSalsa20-Poly1305 encryption
    private let sodium = Sodium()
    private var keyPair: Box.KeyPair?
    private var phantomPublicKey: [UInt8]?
    private var session: String?
    
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
        
        // Generate new keypair for this session using Sodium
        guard let kp = sodium.box.keyPair() else {
            showErrorAlert("Failed to initialize crypto library")
            return
        }
        self.keyPair = kp
        
        openPhantomConnect()
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
        keyPair = nil
        phantomPublicKey = nil
        session = nil
        logger.info("User logged out")
    }
    
    // MARK: - Private Methods
    
    private func isPhantomInstalled() -> Bool {
        guard let url = URL(string: "phantom://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func openPhantomConnect() {
        guard let kp = keyPair else {
            showErrorAlert("Keys not initialized")
            isLoading = false
            return
        }
        
        let appURL = "aasdf"
        let cluster = network
        
        // Get public key as base58 string
        let publicKeyBase58 = Base58.encode(kp.publicKey)
        
        var components = URLComponents()
        components.scheme = "phantom"
        components.host = "v1"
        components.path = "/connect"
        components.queryItems = [
            URLQueryItem(name: "app_url", value: "https://aasdf.app"),
            URLQueryItem(name: "dapp_encryption_public_key", value: publicKeyBase58),
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
            let errorMsg = params.first(where: { $0.name == "errorMessage" })?.value?.removingPercentEncoding ?? "Connection failed"
            logger.error("Phantom connect error: \(errorCode) - \(errorMsg)")
            showErrorAlert(errorMsg)
            isLoading = false
            return
        }
        
        // Get Phantom's public key for encryption
        guard let phantomPubKeyBase58 = params.first(where: { $0.name == "phantom_encryption_public_key" })?.value,
              let phantomPubKeyBytes = Base58.decode(phantomPubKeyBase58),
              phantomPubKeyBytes.count == 32 else {
            showErrorAlert("Invalid Phantom public key")
            isLoading = false
            return
        }
        
        // Get nonce for decryption
        guard let nonceBase58 = params.first(where: { $0.name == "nonce" })?.value,
              let nonceBytes = Base58.decode(nonceBase58) else {
            showErrorAlert("Missing nonce from Phantom")
            isLoading = false
            return
        }
        
        // Get encrypted data
        guard let dataBase58 = params.first(where: { $0.name == "data" })?.value,
              let encryptedData = Base58.decode(dataBase58) else {
            showErrorAlert("Missing encrypted data from Phantom")
            isLoading = false
            return
        }
        
        // Store Phantom's public key
        self.phantomPublicKey = phantomPubKeyBytes
        
        // Decrypt using Sodium
        guard let kp = self.keyPair,
              let decryptedBytes = sodium.box.open(
                authenticatedCipherText: encryptedData,
                senderPublicKey: phantomPubKeyBytes,
                recipientSecretKey: kp.secretKey,
                nonce: nonceBytes
              ) else {
            logger.error("Decryption failed")
            showErrorAlert("Failed to decrypt connection data")
            isLoading = false
            return
        }
        
        do {
            let decryptedData = Data(decryptedBytes)
            
            // Parse the decrypted JSON
            guard let json = try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any],
                  let publicKey = json["public_key"] as? String,
                  let sessionString = json["session"] as? String else {
                throw CryptoError.decryptionFailed
            }
            
            pendingWalletAddress = publicKey
            session = sessionString
            
            logger.info("Connected wallet: \(publicKey)")
            
            // Now request nonce from backend and prompt for signature
            Task {
                await requestNonceAndSign()
            }
            
        } catch {
            logger.error("Failed to process connect callback: \(error.localizedDescription)")
            showErrorAlert("Failed to establish secure connection: \(error.localizedDescription)")
            isLoading = false
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
        guard let kp = keyPair,
              let phantomKey = phantomPublicKey,
              let sessionString = session else {
            showErrorAlert("Missing session data")
            isLoading = false
            return
        }
        
        let appURL = "aasdf"
        
        // Create payload to encrypt
        let payload: [String: Any] = [
            "message": Data(message.utf8).base58EncodedString(),
            "session": sessionString,
            "display": "utf8"
        ]
        
        do {
            let payloadData = try JSONSerialization.data(withJSONObject: payload)
            
            // Generate random nonce (24 bytes)
            guard let nonce = sodium.randomBytes.buf(length: 24) else {
                showErrorAlert("Failed to generate nonce")
                return
            }
            
            // Encrypt using Sodium
            guard let encryptedBytes = sodium.box.seal(
                message: [UInt8](payloadData),
                recipientPublicKey: phantomKey,
                senderSecretKey: kp.secretKey,
                nonce: nonce
            ) else {
                showErrorAlert("Encryption failed")
                return
            }
            
            let publicKeyBase58 = Base58.encode(kp.publicKey)
            
            var components = URLComponents()
            components.scheme = "phantom"
            components.host = "v1"
            components.path = "/signMessage"
            components.queryItems = [
                URLQueryItem(name: "dapp_encryption_public_key", value: publicKeyBase58),
                URLQueryItem(name: "nonce", value: Base58.encode(nonce)),
                URLQueryItem(name: "payload", value: Base58.encode(encryptedBytes)),
                URLQueryItem(name: "redirect_link", value: "\(appURL)://onSignMessage")
            ]
            
            guard let url = components.url else {
                showErrorAlert("Failed to create sign URL")
                isLoading = false
                return
            }
            
            logger.info("Opening Phantom for signing")
            UIApplication.shared.open(url)
            
        } catch {
            logger.error("Failed to encrypt sign request: \(error.localizedDescription)")
            showErrorAlert("Failed to prepare signature request")
            isLoading = false
        }
    }
    
    private func handleSignMessageCallback(components: URLComponents) {
        guard let params = components.queryItems else {
            showErrorAlert("Invalid sign callback")
            isLoading = false
            return
        }
        
        // Check for error
        if let errorCode = params.first(where: { $0.name == "errorCode" })?.value {
            let errorMsg = params.first(where: { $0.name == "errorMessage" })?.value?.removingPercentEncoding ?? "Signing failed"
            logger.error("Phantom sign error: \(errorCode) - \(errorMsg)")
            showErrorAlert(errorMsg)
            isLoading = false
            return
        }
        
        // Get nonce and encrypted data
        guard let nonceBase58 = params.first(where: { $0.name == "nonce" })?.value,
              let nonceBytes = Base58.decode(nonceBase58),
              let dataBase58 = params.first(where: { $0.name == "data" })?.value,
              let encryptedData = Base58.decode(dataBase58) else {
            showErrorAlert("Missing signature data")
            isLoading = false
            return
        }
        
        // Decrypt using Sodium
        guard let kp = self.keyPair,
              let phantomKey = self.phantomPublicKey,
              let decryptedBytes = sodium.box.open(
                authenticatedCipherText: encryptedData,
                senderPublicKey: phantomKey,
                recipientSecretKey: kp.secretKey,
                nonce: nonceBytes
              ) else {
            logger.error("Decryption failed")
            showErrorAlert("Failed to decrypt signature")
            isLoading = false
            return
        }
        
        do {
            let decryptedData = Data(decryptedBytes)
            
            // Parse the signature
            guard let json = try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any],
                  let signatureBase58 = json["signature"] as? String else {
                throw CryptoError.decryptionFailed
            }
            
            logger.info("Received signature, verifying with backend")
            
            Task {
                await verifySignature(signature: signatureBase58)
            }
            
        } catch {
            logger.error("Failed to parse signature: \(error.localizedDescription)")
            showErrorAlert("Failed to process signature")
            isLoading = false
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

// MARK: - Crypto Errors

enum CryptoError: LocalizedError {
    case keyGenerationFailed
    case encryptionFailed
    case decryptionFailed
    case missingSharedSecret
    
    var errorDescription: String? {
        switch self {
        case .keyGenerationFailed: return "Failed to generate encryption keys"
        case .encryptionFailed: return "Failed to encrypt data"
        case .decryptionFailed: return "Failed to decrypt data"
        case .missingSharedSecret: return "Missing shared secret"
        }
    }
}
