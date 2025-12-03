//
//  APIService.swift
//  dev-aasdf
//

import Foundation
import os.log

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
    
    private let baseURL = "http://0.0.0.0:8000" // Change to production URL
    private let logger = Logger(subsystem: "com.aasdf.app", category: "APIService")
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }
    
    // MARK: - Auth Endpoints
    
    func requestNonce(walletAddress: String, network: String) async throws -> NonceResponse {
        let endpoint = "\(baseURL)/auth/nonce"
        let body = NonceRequest(walletAddress: walletAddress, network: network)
        
        return try await post(endpoint: endpoint, body: body)
    }
    
    func verifySignature(walletAddress: String, signature: String, nonce: String, network: String) async throws -> VerifyResponse {
        let endpoint = "\(baseURL)/auth/verify"
        let body = VerifyRequest(
            walletAddress: walletAddress,
            signature: signature,
            nonce: nonce,
            network: network
        )
        
        return try await post(endpoint: endpoint, body: body)
    }
    
    func getCurrentUser() async throws -> UserData {
        let endpoint = "\(baseURL)/auth/me"
        return try await get(endpoint: endpoint, authenticated: true)
    }
    
    // MARK: - Private Methods
    
    private func get<T: Decodable>(endpoint: String, authenticated: Bool = false) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
        
        if authenticated, let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try encoder.encode(body)
        
        return try await execute(request: request)
    }
    
    private func execute<T: Decodable>(request: URLRequest) async throws -> T {
        logger.info("API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        logger.info("API Response: \(httpResponse.statusCode)")
        
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
            } else {
                errorMessage = "Server error"
            }
            logger.error("Server error \(httpResponse.statusCode): \(errorMessage)")
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }
    }
}
