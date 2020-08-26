//
//  OAuthToken.swift
//  Scrapple
//
//  Created by Linus Skucas on 8/2/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import Foundation

struct OAuthToken {
    static let keychainAccount = "sh.linus.Scrapple"
    
    #if DEBUG
    static let teamId = "AZ73FT4DU9"
    #else
    static let teamId = "P6PV2R9443"
    #endif
    
    var oauthToken: String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: Self.keychainAccount,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecAttrAccessGroup as String: "\(Self.teamId).sh.linus.Scrapple.shared",
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else { return nil }
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let token = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            return nil
        }
        return token
    }
    
    static let shared = OAuthToken()
    
    func addToKeychain(name: String, token: String) throws {
        let password = token.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: Self.keychainAccount,
                                    kSecAttrAccessGroup as String: "\(Self.teamId).sh.linus.Scrapple.shared",
                                    kSecValueData as String: password]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status)}
    }
    
    func deleteFromKeychain() {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: Self.keychainAccount,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        SecItemDelete(query as CFDictionary)
    }

}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}


