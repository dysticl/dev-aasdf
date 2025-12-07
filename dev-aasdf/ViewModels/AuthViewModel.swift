//
//  AuthViewModel.swift
//  dev-aasdf
//

import Combine
import Foundation
import Sodium
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
    private let network = "devnet"

    private let sodium = Sodium()
    private var keyPair: Box.KeyPair?
    private var phantomPublicKey: Bytes?
    private var session: String?

    // MARK: - Public Methods

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

    func connectPhantomWallet() async {
        guard isPhantomInstalled() else {
            showErrorAlert(
                "Phantom wallet not installed. Please install Phantom from the App Store.")
            return
        }

        isLoading = true
        errorMessage = nil

        guard let kp = sodium.box.keyPair() else {
            showErrorAlert("Failed to initialize crypto library")
            isLoading = false
            return
        }
        self.keyPair = kp

        openPhantomConnect()
    }

    func handleDeeplink(url: URL) {
        logger.info("Received deeplink: \(url.absoluteString)")

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = components.host
        else {
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

        logger.info("Public key size: \(kp.publicKey.count) bytes")

        guard kp.publicKey.count == 32 else {
            logger.error("Invalid public key size: \(kp.publicKey.count), expected 32")
            showErrorAlert("Invalid key size generated")
            isLoading = false
            return
        }

        let publicKeyBase58 = Base58.encode(kp.publicKey)

        if let decoded = Base58.decode(publicKeyBase58) {
            logger.info(
                "Decoded key size: \(decoded.count) bytes, matches: \(decoded == kp.publicKey)")
        }

        logger.info("Public key base58: \(publicKeyBase58)")

        var components = URLComponents()
        components.scheme = "phantom"
        components.host = "v1"
        components.path = "/connect"
        components.queryItems = [
            URLQueryItem(name: "app_url", value: "http://192.168.178.94:8000/"),
            URLQueryItem(name: "dapp_encryption_public_key", value: publicKeyBase58),
            URLQueryItem(name: "cluster", value: cluster),
            URLQueryItem(name: "redirect_link", value: "\(appURL)://onConnect"),
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

        if let errorCode = params.first(where: { $0.name == "errorCode" })?.value {
            let errorMsg =
                params.first(where: { $0.name == "errorMessage" })?.value?.removingPercentEncoding
                ?? "Connection failed"
            logger.error("Phantom connect error: \(errorCode) - \(errorMsg)")
            showErrorAlert(errorMsg)
            isLoading = false
            return
        }

        guard
            let phantomPubKeyBase58 = params.first(where: {
                $0.name == "phantom_encryption_public_key"
            })?.value,
            let phantomPubKeyBytes = Base58.decode(phantomPubKeyBase58),
            phantomPubKeyBytes.count == 32
        else {
            showErrorAlert("Invalid Phantom public key")
            isLoading = false
            return
        }

        guard let nonceBase58 = params.first(where: { $0.name == "nonce" })?.value,
            let nonceBytes = Base58.decode(nonceBase58)
        else {
            showErrorAlert("Missing nonce from Phantom")
            isLoading = false
            return
        }

        guard let dataBase58 = params.first(where: { $0.name == "data" })?.value,
            let encryptedData = Base58.decode(dataBase58)
        else {
            showErrorAlert("Missing encrypted data from Phantom")
            isLoading = false
            return
        }

        self.phantomPublicKey = phantomPubKeyBytes

        guard let kp = self.keyPair,
            let decryptedBytes = sodium.box.open(
                authenticatedCipherText: encryptedData,
                senderPublicKey: phantomPubKeyBytes,
                recipientSecretKey: kp.secretKey,
                nonce: nonceBytes
            )
        else {
            logger.error("Decryption failed")
            showErrorAlert("Failed to decrypt connection data")
            isLoading = false
            return
        }

        do {
            let decryptedData = Data(decryptedBytes)

            logger.info("Decrypted data: \(String(data: decryptedData, encoding: .utf8) ?? "nil")")

            guard
                let json = try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any],
                let publicKey = json["public_key"] as? String,
                let sessionString = json["session"] as? String
            else {
                throw CryptoError.decryptionFailed
            }

            logger.info("Connected wallet: \(publicKey)")
            self.session = sessionString

            // Step 2: Request Nonce from Backend
            Task {
                do {
                    let nonceResponse = try await apiService.getNonce(walletAddress: publicKey)
                    logger.info("Got nonce: \(nonceResponse.nonce)")

                    // Step 3: Sign Message via Phantom
                    openPhantomSignMessage(
                        message: nonceResponse.message, nonce: nonceResponse.nonce,
                        walletAddress: publicKey)
                } catch {
                    logger.error("Failed to get nonce: \(error.localizedDescription)")
                    showErrorAlert("Failed to initialize login sequence")
                }
            }

        } catch {
            logger.error("Failed to process connect callback: \(error.localizedDescription)")
            showErrorAlert("Failed to establish secure connection: \(error.localizedDescription)")
            isLoading = false
        }
    }

    private func openPhantomSignMessage(message: String, nonce: String, walletAddress: String) {
        guard let kp = keyPair, let phantomKey = phantomPublicKey else { return }
        self.pendingNonce = nonce
        self.pendingWalletAddress = walletAddress

        let payload = ["message": message, "session": session ?? ""]

        guard let payloadData = try? JSONSerialization.data(withJSONObject: payload),
            let encryptedPayload = sodium.box.seal(
                message: payloadData,
                recipientPublicKey: phantomKey,
                senderSecretKey: kp.secretKey
            )
        else {
            showErrorAlert("Encryption failed")
            return
        }

        let payloadBase58 = Base58.encode(encryptedPayload)
        let publicKeyBase58 = Base58.encode(kp.publicKey)

        var components = URLComponents()
        components.scheme = "phantom"
        components.host = "v1"
        components.path = "/signMessage"
        components.queryItems = [
            URLQueryItem(name: "dapp_encryption_public_key", value: publicKeyBase58),
            URLQueryItem(name: "nonce", value: Base58.encode(sodium.randomBytes.buf(length: 24)!)),
            URLQueryItem(name: "redirect_link", value: "aasdf://onSignMessage"),
            URLQueryItem(name: "payload", value: payloadBase58),
        ]

        if let url = components.url {
            UIApplication.shared.open(url)
        }
    }

    private func handleSignMessageCallback(components: URLComponents) {
        guard let params = components.queryItems,
            let nonceBase58 = params.first(where: { $0.name == "nonce" })?.value,
            let dataBase58 = params.first(where: { $0.name == "data" })?.value,
            let nonceBytes = Base58.decode(nonceBase58),
            let encryptedData = Base58.decode(dataBase58),
            let kp = keyPair,
            let phantomKey = phantomPublicKey
        else {
            showErrorAlert("Invalid sign callback")
            return
        }

        guard
            let decryptedBytes = sodium.box.open(
                authenticatedCipherText: encryptedData,
                senderPublicKey: phantomKey,
                recipientSecretKey: kp.secretKey,
                nonce: nonceBytes
            )
        else {
            showErrorAlert("Decryption failed")
            return
        }

        do {
            let decryptedData = Data(decryptedBytes)
            guard
                let json = try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any],
                let signature = json["signature"] as? String
            else {
                showErrorAlert("Invalid signature format")
                return
            }

            guard let walletAddress = pendingWalletAddress, let nonce = pendingNonce else {
                showErrorAlert("State lost")
                return
            }

            // Step 4: Verify Signature
            Task {
                do {
                    let response = try await apiService.verifySignature(
                        walletAddress: walletAddress,
                        signature: signature,
                        nonce: nonce
                    )

                    KeychainHelper.shared.saveToken(response.accessToken)

                    let user = try await apiService.getCurrentUser()
                    self.currentUser = user
                    self.isAuthenticated = true

                    let welcomeText =
                        response.isNewUser
                        ? "Welcome, new Hunter! Balance: \(String(format: "%.4f", response.balanceSol)) SOL"
                        : "Welcome back! Balance: \(String(format: "%.4f", response.balanceSol)) SOL"
                    showWelcome(message: welcomeText)

                } catch {
                    logger.error("Verification failed: \(error.localizedDescription)")
                    showErrorAlert("Login failed: \(error.localizedDescription)")
                }
                isLoading = false
            }
        } catch {
            showErrorAlert("Data error")
        }
    }

    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
        isLoading = false
    }

    private func showWelcome(message: String) {
        welcomeMessage = message
        showWelcomeToast = true

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
        case .keyGenerationFailed:
            return "Failed to generate encryption keys"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .missingSharedSecret:
            return "Missing shared secret"
        }
    }
}
