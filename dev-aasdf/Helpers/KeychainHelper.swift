//
//  KeychainHelper.swift
//  dev-aasdf
//

import Foundation
import Security
import os.log

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private let service = "com.aasdf.app"
    private let tokenKey = "auth_token"
    private let logger = Logger(subsystem: "com.aasdf.app", category: "Keychain")
    
    private init() {}
    
    // MARK: - Token Management
    
    func saveToken(_ token: String) {
        guard let data = token.data(using: .utf8) else {
            logger.error("Failed to convert token to data")
            return
        }
        
        // Delete existing token first
        deleteToken()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            logger.info("Token saved successfully")
        } else {
            logger.error("Failed to save token: \(status)")
        }
    }
    
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            logger.info("Token deleted")
        } else {
            logger.error("Failed to delete token: \(status)")
        }
    }
}
