//
//  APIService.swift
//  dev-aasdf
//

import Foundation
import os.log
import UIKit // Needed for UIImage

// MARK: - API Models

struct NonceRequest: Codable {
    let walletAddress: String
    let network: String
    
    enum CodingKeys: String, CodingKey {
        case walletAddress = "wallet_address"
        case network
    }
}

struct NonceResponse: Codable {
    let nonce: String
    let message: String
    let expiresAt: String
    
    enum CodingKeys: String, CodingKey {
        case nonce
        case message
        case expiresAt = "expires_at"
    }
}

struct VerifyRequest: Codable {
    let walletAddress: String
    let signature: String
    let nonce: String
    let network: String
    
    enum CodingKeys: String, CodingKey {
        case walletAddress = "wallet_address"
        case signature
        case nonce
        case network
    }
}

struct VerifyResponse: Codable {
    let accessToken: String
    let userId: String
    let isNewUser: Bool
    let balanceSol: Double
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case userId = "user_id"
        case isNewUser = "is_new_user"
        case balanceSol = "balance_sol"
    }
}

struct UserData: Codable {
    let username: String
    let wallet: WalletData
}

struct WalletData: Codable {
    let address: String
    let network: String
    let balanceSol: Double
    
    enum CodingKeys: String, CodingKey {
        case address
        case network
        case balanceSol = "balance_sol"
    }
}

struct APIErrorResponse: Codable {
    let detail: String
}

struct ConnectRequest: Codable {
    let walletAddress: String
    let phantomSession: String
    let network: String
    
    enum CodingKeys: String, CodingKey {
        case walletAddress = "wallet_address"
        case phantomSession = "phantom_session"
        case network
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String)
    case unauthorized
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data error: \(error.localizedDescription)"
        case .serverError(_, let message):
            return message
        case .unauthorized:
            return "Session expired. Please login again."
        case .unknown:
            return "An unknown error occurred"
        }
    }
    
    var errorDescription: String? { message }
}

// MARK: - API Service

class APIService {
    static let shared = APIService()
    
    // Daniels lokale Entwicklungs-IP (Mac im WLAN)
    // Bei Änderung: Terminal -> ipconfig getifaddr en0
    private let baseURL = "http://192.168.178.94:8000"
    
    private let logger = Logger(subsystem: "com.aasdf.app", category: "APIService")
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let session: URLSession
    
    private init() {
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        
        // Konfiguriere URLSession mit längerem Timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30 // 30 Sekunden für Request
        config.timeoutIntervalForResource = 60 // 60 Sekunden für Resource
        config.waitsForConnectivity = true // Warte auf Netzwerk
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        
        session = URLSession(configuration: config)
    }
    
    // MARK: - Auth Endpoints
    
    func connectWallet(walletAddress: String, phantomSession: String, network: String) async throws -> VerifyResponse {
        let endpoint = "\(baseURL)/auth/connect"
        let body = ConnectRequest(walletAddress: walletAddress, phantomSession: phantomSession, network: network)
        
        return try await post(endpoint: endpoint, body: body)
    }
    
    func getCurrentUser() async throws -> UserData {
        let endpoint = "\(baseURL)/auth/me"
        return try await get(endpoint: endpoint, authenticated: true)
    }
    
    // MARK: - User Endpoints
    
    func fetchMyProfile() async throws -> UserProfile {
        let endpoint = "\(baseURL)/users/me"
        return try await get(endpoint: endpoint, authenticated: true)
    }
    
    func updateUsername(_ newName: String) async throws -> UserProfile {
        let endpoint = "\(baseURL)/users/me"
        let body = UpdateUsernameRequest(username: newName)
        // PATCH request implementation using existing post logic but with PATCH method
        // Since existing post() is hardcoded to POST, we'll create a generic request helper or just implement it here manually for simplicity
        
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try encoder.encode(body)
        return try await execute(request: request)
    }
    
    func deactivateAccount() async throws {
        let endpoint = "\(baseURL)/users/me/deactivate"
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let _: EmptyResponse = try await execute(request: request)
    }
    
    func uploadProfilePic(_ image: UIImage) async throws {
        let endpoint = "\(baseURL)/users/me/profile-pic"
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        guard let imageData = image.pngData() else {
            throw APIError.unknown // Image conversion failed
        }
        
        request.httpBody = createMultipartBody(data: imageData, boundary: boundary, filename: "profile.png", mimeType: "image/png")
        
        let _: EmptyResponse = try await execute(request: request)
    }
    
    // MARK: - Private Methods
    
    private func get<T: Decodable>(endpoint: String, authenticated: Bool = false) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        if authenticated, let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return try await execute(request: request)
    }
    
    private func post<T: Decodable, B: Encodable>(endpoint: String, body: B, authenticated: Bool = false) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        if authenticated, let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try encoder.encode(body)
        
        return try await execute(request: request)
    }
    
    private func execute<T: Decodable>(request: URLRequest) async throws -> T {
        logger.info("API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        
        // Debug: Log request body if present
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            logger.info("Request body: \(bodyString)")
        }
        
        let (data, response): (Data, URLResponse)
        
        do {
            // Verwende die konfigurierte Session statt URLSession.shared
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            logger.error("URLError: \(error.code.rawValue) - \(error.localizedDescription)")
            
            // Bessere Fehlermeldungen
            switch error.code {
            case .timedOut:
                throw APIError.networkError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server nicht erreichbar. Stelle sicher, dass dein Backend läuft und die IP korrekt ist."]))
            case .cannotConnectToHost:
                throw APIError.networkError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kann nicht zum Server verbinden. Prüfe die IP-Adresse und ob Docker läuft."]))
            case .notConnectedToInternet:
                throw APIError.networkError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Keine Internetverbindung."]))
            default:
                throw APIError.networkError(error)
            }
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        logger.info("API Response: \(httpResponse.statusCode)")
        
        // Debug: Log response body
        if let responseString = String(data: data, encoding: .utf8) {
            logger.info("Response body: \(responseString)")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                logger.error("Decoding error: \(error.localizedDescription)")
                throw APIError.decodingError(error)
            }
            
        case 401:
            throw APIError.unauthorized
            
        default:
            let errorMessage: String
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                errorMessage = errorResponse.detail
            } else if let responseString = String(data: data, encoding: .utf8) {
                errorMessage = responseString
            } else {
                errorMessage = "Server error"
            }
            logger.error("Server error \(httpResponse.statusCode): \(errorMessage)")
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }
    }
    
    // MARK: - Private Helpers
    
    private func createMultipartBody(data: Data, boundary: String, filename: String, mimeType: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\(lineBreak)")
        body.append("Content-Type: \(mimeType)\(lineBreak + lineBreak)")
        body.append(data)
        body.append(lineBreak)
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
}

// Helper struct for empty responses
struct EmptyResponse: Codable {}

// Extension to append string to Data
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
