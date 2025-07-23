import Foundation

// MARK: - Forgot Password Use Case
protocol ForgotPasswordUseCaseProtocol {
    func execute(email: String) async throws
}

class ForgotPasswordUseCase: ForgotPasswordUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute(email: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        try await authRepository.forgotPassword(email: email)
    }
}

// MARK: - Verification Code Use Case
protocol VerificationCodeUseCaseProtocol {
    func execute(email: String, code: String) async throws -> Bool
}

class VerificationCodeUseCase: VerificationCodeUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute(email: String, code: String) async throws -> Bool {
        guard !email.isEmpty, !code.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        return try await authRepository.verifyCode(email: email, code: code)
    }
} 