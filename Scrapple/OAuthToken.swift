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
    
    var oauthToken: String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: Self.keychainAccount,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
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
                                    kSecValueData as String: password]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status)}
    }

}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}


