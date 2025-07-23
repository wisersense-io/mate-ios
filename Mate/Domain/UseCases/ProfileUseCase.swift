import Foundation

// MARK: - Profile Use Case Protocol
protocol ProfileUseCaseProtocol {
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) async throws -> Bool
    func validatePasswordChange(oldPassword: String, newPassword: String, confirmPassword: String) throws
}

// MARK: - Profile Use Case Implementation
class ProfileUseCase: ProfileUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    
    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) async throws -> Bool {
        // Validate inputs first
        try validatePasswordChange(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)
        
        // Call repository to change password
        return try await profileRepository.changePassword(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)
    }
    
    func validatePasswordChange(oldPassword: String, newPassword: String, confirmPassword: String) throws {
        // Check if old password is not empty
        guard !oldPassword.isEmpty else {
            throw ProfileError.emptyOldPassword
        }
        
        // Check if new password is not empty
        guard !newPassword.isEmpty else {
            throw ProfileError.emptyNewPassword
        }
        
        // Check if confirm password is not empty
        guard !confirmPassword.isEmpty else {
            throw ProfileError.emptyConfirmPassword
        }
        
        // Check if new password and confirm password match
        guard newPassword == confirmPassword else {
            throw ProfileError.passwordsDoNotMatch
        }
        
        // Check if new password is at least 6 characters
        guard newPassword.count >= 6 else {
            throw ProfileError.passwordTooShort
        }
        
        // Check if old password and new password are different
        guard oldPassword != newPassword else {
            throw ProfileError.samePassword
        }
    }
}

// MARK: - Profile Error
enum ProfileError: LocalizedError {
    case emptyOldPassword
    case emptyNewPassword
    case emptyConfirmPassword
    case passwordsDoNotMatch
    case passwordTooShort
    case samePassword
    case changePasswordFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyOldPassword:
            return "old_password_empty".localized()
        case .emptyNewPassword:
            return "new_password_empty".localized()
        case .emptyConfirmPassword:
            return "confirm_password_empty".localized()
        case .passwordsDoNotMatch:
            return "passwords_do_not_match".localized()
        case .passwordTooShort:
            return "password_too_short".localized()
        case .samePassword:
            return "same_password_error".localized()
        case .changePasswordFailed(let message):
            return message
        }
    }
} 