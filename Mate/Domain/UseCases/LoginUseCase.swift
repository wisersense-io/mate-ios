import Foundation

// MARK: - Use Cases
protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> User
}

class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute(email: String, password: String) async throws -> User {
        // Validate input
        guard isValidEmail(email), !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        let credentials = LoginCredentials(email: email, password: password)
        let result = try await authRepository.login(credentials: credentials)
        
        // Save token automatically after successful login
        try authRepository.saveToken(result.token)
        
        // Save user session
        UserSessionManager.shared.setUser(result.user)
        
        return result.user
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
}

// MARK: - Auth Errors
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case invalidURL
    case invalidResponse
    case serverError(String, errorCode: Int)
    case tokenStorage
    case userNotFound
    case userInactive
    case emailNotConfirmed
    case passwordTemporary
    case networkError
    case unknownError(errorCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "invalid_email_password".localized()
        case .invalidURL:
            return "invalid_url".localized()
        case .invalidResponse:
            return "invalid_response".localized()
        case .serverError(let message, _):
            return message.isEmpty ? "login_failed".localized() : message
        case .tokenStorage:
            return "token_storage_error".localized()
        case .userNotFound:
            return "user_not_found".localized()
        case .userInactive:
            return "user_inactive".localized()
        case .emailNotConfirmed:
            return "email_not_confirmed".localized()
        case .passwordTemporary:
            return "password_temporary".localized()
        case .networkError:
            return "network_error".localized()
        case .unknownError(let errorCode):
            return "unknown_error_code".localized() + " (\(errorCode))"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .serverError(_, let code), .unknownError(let code):
            return code
        default:
            return 0
        }
    }
} 