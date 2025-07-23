import Foundation

// MARK: - Token Storage Protocol
protocol TokenStorageServiceProtocol {
    func saveToken(_ token: AuthToken) throws
    func getToken() -> AuthToken?
    func clearToken()
    func isTokenValid() -> Bool
}

// MARK: - UserDefaults Token Storage Implementation
class UserDefaultsTokenStorageService: TokenStorageServiceProtocol {
    
    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let expiresAt = "token_expires_at"
    }
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveToken(_ token: AuthToken) throws {
        userDefaults.set(token.accessToken, forKey: Keys.accessToken)
        
        if let refreshToken = token.refreshToken {
            userDefaults.set(refreshToken, forKey: Keys.refreshToken)
        }
        
        if let expiresAt = token.expiresAt {
            userDefaults.set(expiresAt, forKey: Keys.expiresAt)
        }
        
        // Ensure data is persisted immediately
        guard userDefaults.synchronize() else {
            throw AuthError.tokenStorage
        }
    }
    
    func getToken() -> AuthToken? {
        guard let accessToken = userDefaults.string(forKey: Keys.accessToken),
              !accessToken.isEmpty else {
            return nil
        }
        
        let refreshToken = userDefaults.string(forKey: Keys.refreshToken)
        let expiresAt = userDefaults.object(forKey: Keys.expiresAt) as? Date
        
        return AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }
    
    func clearToken() {
        userDefaults.removeObject(forKey: Keys.accessToken)
        userDefaults.removeObject(forKey: Keys.refreshToken)
        userDefaults.removeObject(forKey: Keys.expiresAt)
        userDefaults.synchronize()
    }
    
    func isTokenValid() -> Bool {
        guard let token = getToken() else { return false }
        
        // Check if token has expiration date
        if let expiresAt = token.expiresAt {
            return Date() < expiresAt
        }
        
        // If no expiration date, consider it valid if exists
        return !token.accessToken.isEmpty
    }
} 