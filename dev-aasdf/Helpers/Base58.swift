//
//  Base58.swift
//  dev-aasdf
//
//  Base58 encoding/decoding for Solana/Phantom communication
//

import Foundation

enum Base58 {
    private static let alphabet = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
    private static let base: UInt32 = 58
    private static let alphabetMap: [Character: UInt8] = {
        var map = [Character: UInt8]()
        for (index, char) in alphabet.enumerated() {
            map[char] = UInt8(index)
        }
        return map
    }()
    
    /// Encode bytes to Base58 string
    static func encode(_ bytes: [UInt8]) -> String {
        guard !bytes.isEmpty else { return "" }
        
        // Count leading zeros
        var leadingZeros = 0
        for byte in bytes {
            if byte == 0 {
                leadingZeros += 1
            } else {
                break
            }
        }
        
        // Allocate enough space for the result
        // log(256) / log(58) ≈ 1.37, so we need at most size * 137/100 + 1
        let maxSize = bytes.count * 137 / 100 + 1
        var result = [UInt8](repeating: 0, count: maxSize)
        var resultLength = 0
        
        // Process each byte
        for byte in bytes {
            var carry = UInt32(byte)
            var j = 0
            
            // Apply "b58 = b58 * 256 + byte"
            var i = maxSize - 1
            while i >= 0 && (carry != 0 || j < resultLength) {
                carry += 256 * UInt32(result[i])
                result[i] = UInt8(carry % base)
                carry /= base
                j += 1
                if i > 0 {
                    i -= 1
                } else {
                    break
                }
            }
            resultLength = j
        }
        
        // Skip leading zeros in result
        var startIndex = maxSize - resultLength
        while startIndex < maxSize && result[startIndex] == 0 {
            startIndex += 1
        }
        
        // Build the result string with leading '1's for each leading zero byte
        var encoded = String(repeating: "1", count: leadingZeros)
        for i in startIndex..<maxSize {
            encoded.append(alphabet[Int(result[i])])
        }
        
        return encoded
    }
    
    /// Decode Base58 string to bytes
    static func decode(_ string: String) -> [UInt8]? {
        guard !string.isEmpty else { return [] }
        
        // Count leading '1's (represent leading zero bytes)
        var leadingOnes = 0
        for char in string {
            if char == "1" {
                leadingOnes += 1
            } else {
                break
            }
        }
        
        // Allocate enough space
        // log(58) / log(256) ≈ 0.73, so we need at most size * 733/1000 + 1
        let maxSize = string.count * 733 / 1000 + 1
        var result = [UInt8](repeating: 0, count: maxSize)
        var resultLength = 0
        
        // Process each character
        for char in string {
            guard let value = alphabetMap[char] else {
                return nil // Invalid character
            }
            
            var carry = UInt32(value)
            var j = 0
            
            // Apply "b256 = b256 * 58 + value"
            var i = maxSize - 1
            while i >= 0 && (carry != 0 || j < resultLength) {
                carry += 58 * UInt32(result[i])
                result[i] = UInt8(carry % 256)
                carry /= 256
                j += 1
                if i > 0 {
                    i -= 1
                } else {
                    break
                }
            }
            resultLength = j
        }
        
        // Skip leading zeros in result
        var startIndex = maxSize - resultLength
        while startIndex < maxSize && result[startIndex] == 0 {
            startIndex += 1
        }
        
        // Build result with leading zero bytes
        var decoded = [UInt8](repeating: 0, count: leadingOnes)
        decoded.append(contentsOf: result[startIndex..<maxSize])
        
        return decoded
    }
}

// MARK: - Data Extension

extension Data {
    func base58EncodedString() -> String {
        Base58.encode(Array(self))
    }
    
    init?(base58Encoded string: String) {
        guard let bytes = Base58.decode(string) else {
            return nil
        }
        self.init(bytes)
    }
}
