import Foundation

// MARK: - Domain Entities
struct User {
    let id: String
    let name: String
    let userName: String
    let email: String
    let role: Int
    let jobType: String
    let defaultLanguage: String
    let timeZone: String
    let isActive: Bool
    let isEmailConfirmed: Bool
    let isPwdTemporary: Bool
    let organizationId: String?
    let tenantId: String?
    let organizations: [UserOrganization]
    let lastSigninAt: Date?
    let isNotificationEmailActive: Bool
    let isNotificationInAppActive: Bool
}

struct UserOrganization {
    let id: String
    let name: String
    let tenantId: String
    let tenantName: String
}

struct AuthToken {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date?
}

struct LoginCredentials {
    let email: String
    let password: String
} 