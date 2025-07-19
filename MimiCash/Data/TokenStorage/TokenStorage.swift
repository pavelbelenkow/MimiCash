import Foundation
import Security

// MARK: - TokenStorage Protocol

protocol TokenStorage {
    var token: String? { get }
    
    func setToken(_ token: String?)
    func clearToken()
}

// MARK: - Keychain Token Storage

@Observable
final class KeychainTokenStorage: TokenStorage {
    
    static let shared = KeychainTokenStorage()
    
    // MARK: - Private Properties
    private let service = "com.mimicash.auth"
    private let account = "access_token"
    
    // MARK: - Properties
    var token: String?
    
    // MARK: - Init
    private init() {
        token = loadToken()
    }
    
    // MARK: - Methods
    func setToken(_ token: String?) {
        self.token = token
        
        if let token {
            saveToken(token)
        } else {
            deleteToken()
        }
    }
    
    func clearToken() {
        token = nil
        deleteToken()
    }
    
    // MARK: - Private Methods
    private func saveToken(_ token: String) {
        guard let data = token.data(using: .utf8) else {
            print("Failed to convert token to data")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let updateAttributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
        
        if updateStatus == errSecItemNotFound {
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            if addStatus != errSecSuccess {
                print("Failed to add token to keychain: \(addStatus)")
            }
        } else if updateStatus != errSecSuccess {
            print("Failed to update token in keychain: \(updateStatus)")
        }
    }
    
    private func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            if status != errSecItemNotFound {
                print("Failed to load token from keychain: \(status)")
            }
            return nil
        }
        
        return token
    }
    
    private func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Failed to delete token from keychain: \(status)")
        }
    }
}
