//
//  KeychainManager.swift
//  SpotFinder
//
//  Secure storage for authentication tokens
//

import Foundation
import Security

actor KeychainManager {
    static let shared = KeychainManager()
    
    private let accessTokenKey = "com.spotfinder.accessToken"
    private let refreshTokenKey = "com.spotfinder.refreshToken"
    
    private init() {}
    
    // MARK: - Access Token
    
    func saveAccessToken(_ token: String) throws {
        try save(token, forKey: accessTokenKey)
    }
    
    func getAccessToken() -> String? {
        return get(forKey: accessTokenKey)
    }
    
    func deleteAccessToken() throws {
        try delete(forKey: accessTokenKey)
    }
    
    // MARK: - Refresh Token
    
    func saveRefreshToken(_ token: String) throws {
        try save(token, forKey: refreshTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return get(forKey: refreshTokenKey)
    }
    
    func deleteRefreshToken() throws {
        try delete(forKey: refreshTokenKey)
    }
    
    // MARK: - Clear All
    
    func clearAll() throws {
        try deleteAccessToken()
        try deleteRefreshToken()
    }
    
    // MARK: - Private Helpers
    
    private func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        
        // Delete existing item if it exists
        try? delete(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }
    
    private func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
}

enum KeychainError: Error {
    case encodingFailed
    case saveFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    
    var localizedDescription: String {
        switch self {
        case .encodingFailed:
            return "Failed to encode value"
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        }
    }
}
