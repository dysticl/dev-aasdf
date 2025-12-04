//
//  Base58.swift
//  dev-aasdf
//
//  Base58 encoding/decoding for Solana/Phantom communication
//

import Foundation

enum Base58 {
    private static let alphabet = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
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
        
        // Allocate enough space in big-endian base58 representation
        let size = bytes.count * 138 / 100 + 1
        var b58 = [UInt8](repeating: 0, count: size)
        
        // Process the bytes
        for byte in bytes {
            var carry = Int(byte)
            var i = size - 1
            
            while carry != 0 || i >= size - (bytes.count - leadingZeros) {
                carry += 256 * Int(b58[i])
                b58[i] = UInt8(carry % 58)
                carry /= 58
                if i > 0 {
                    i -= 1
                } else {
                    break
                }
            }
        }
        
        // Skip leading zeros in base58 result
        var startIndex = 0
        while startIndex < size && b58[startIndex] == 0 {
            startIndex += 1
        }
        
        // Build the result string
        var result = String(repeating: "1", count: leadingZeros)
        for i in startIndex..<size {
            result.append(alphabet[Int(b58[i])])
        }
        
        return result
    }
    
    /// Decode Base58 string to bytes
    static func decode(_ string: String) -> [UInt8]? {
        guard !string.isEmpty else { return [] }
        
        // Count leading '1's (zeros in base58)
        var leadingOnes = 0
        for char in string {
            if char == "1" {
                leadingOnes += 1
            } else {
                break
            }
        }
        
        // Allocate enough space
        let size = string.count * 733 / 1000 + 1
        var b256 = [UInt8](repeating: 0, count: size)
        
        // Process each character
        for char in string {
            guard let value = alphabetMap[char] else {
                return nil // Invalid character
            }
            
            var carry = Int(value)
            var i = size - 1
            
            while carry != 0 || i >= size - (string.count - leadingOnes) {
                carry += 58 * Int(b256[i])
                b256[i] = UInt8(carry % 256)
                carry /= 256
                if i > 0 {
                    i -= 1
                } else {
                    break
                }
            }
        }
        
        // Skip leading zeros in b256
        var startIndex = 0
        while startIndex < size && b256[startIndex] == 0 {
            startIndex += 1
        }
        
        // Build result with leading zeros
        var result = [UInt8](repeating: 0, count: leadingOnes)
        result.append(contentsOf: b256[startIndex...])
        
        return result
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
