//
//  KeychainHelper.swift
//  Amigos_Shared
//
//  Created by Jarret on 01/05/2025.
//

import Foundation

class KeychainHelper {
    private let keychainGroup: String
    private let service: String

    init(keychainGroup: String, service: String) {
        self.keychainGroup = keychainGroup
        self.service = service
    }

    func set(_ value: String?, forKey key: String) {
        guard let value = value else {
            delete(forKey: key)
            return
        }

        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessGroup as String: keychainGroup,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain set error: \(status)")
        }
    }

    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessGroup as String: keychainGroup
        ]

        var result: AnyObject?
        for attempt in 1...3 {
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            if status == errSecSuccess, let data = result as? Data {
                return String(data: data, encoding: .utf8)
            } else if status != errSecItemNotFound {
                print("Keychain get error (attempt \(attempt)): \(status)")
                usleep(50000)
            }
        }
        return nil
    }

    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecAttrAccessGroup as String: keychainGroup
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychain delete error: \(status)")
        }
    }
}
