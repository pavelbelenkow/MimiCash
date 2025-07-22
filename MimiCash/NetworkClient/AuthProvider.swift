import Foundation

// MARK: - AuthProvider Protocol

protocol AuthProvider {
    func getAuthHeaders() -> [String: String]
}

// MARK: - TokenAuthProvider

final class TokenAuthProvider: AuthProvider {
    
    // MARK: - Private Properties
    private let tokenStorage: TokenStorage
    
    // MARK: - Init
    init(tokenStorage: TokenStorage = KeychainTokenStorage.shared) {
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Methods
    func getAuthHeaders() -> [String: String] {
        guard let token = tokenStorage.token else { return [:] }
        return ["Authorization": "Bearer \(token)"]
    }
}
