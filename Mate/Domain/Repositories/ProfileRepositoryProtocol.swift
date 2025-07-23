import Foundation

// MARK: - Profile Repository Protocol
protocol ProfileRepositoryProtocol {
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String) async throws -> Bool
} 