import Foundation

// MARK: - Change Password Request DTO
struct ChangePasswordRequest: Codable {
    let oldPassword: String
    let newPassword: String
    
    enum CodingKeys: String, CodingKey {
        case oldPassword
        case newPassword
    }
}

// MARK: - Change Password Response DTO
struct ChangePasswordResponse: Codable {
    let errorCode: Int
    let hasError: Bool
    
    enum CodingKeys: String, CodingKey {
        case errorCode
        case hasError
    }
} 