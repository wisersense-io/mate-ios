import Foundation

// MARK: - Profile Repository Implementation
class ProfileRepository: ProfileRepositoryProtocol {
    
    private let networkDataSource: ProfileNetworkDataSourceProtocol
    
    init(networkDataSource: ProfileNetworkDataSourceProtocol) {
        self.networkDataSource = networkDataSource
    }
    
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) async throws -> Bool {
        let response = try await networkDataSource.changePassword(oldPassword: oldPassword, newPassword: newPassword)
        
        // Check for API errors
        if response.hasError {
            print("❌ Change Password API Error: errorCode \(response.errorCode)")
            throw ProfileError.changePasswordFailed("Change password failed with error code: \(response.errorCode)")
        }
        
        // Success if no error
        return true
    }
} 