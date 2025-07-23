import Foundation
import Combine

// MARK: - Repository Protocols
protocol AuthRepositoryProtocol {
    func login(credentials: LoginCredentials) async throws -> (user: User, token: AuthToken)
    func forgotPassword(email: String) async throws
    func verifyCode(email: String, code: String) async throws -> Bool
    func saveToken(_ token: AuthToken) throws
    func getStoredToken() -> AuthToken?
    func clearToken()
    func isLoggedIn() -> Bool
} 