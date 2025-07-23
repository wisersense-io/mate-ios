import Foundation

// MARK: - Request DTOs
struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
    let isMobile: Bool
}

struct ForgotPasswordRequestDTO: Encodable {
    let eMailAddress: String
    let verificationCode: String
}

// MARK: - Response DTOs
struct BaseResponseDTO: Decodable {
    let error: String?
    let errorCode: Int
    
    var hasError: Bool {
        return !(error?.isEmpty ?? true) || errorCode != 0
    }
}

struct LoginResponseDTO: Decodable {
    let token: String?
    let userName: String?
    let email: String?
    let role: Int?
    let organizationId: String?
    let hasError: Bool
    let errorCode: Int
    let currentUser: CurrentUserDTO?
}

struct CurrentUserDTO: Decodable {
    let name: String
    let userName: String
    let email: String
    let password: String?
    let active: Int
    let emailConfirmed: Int
    let pwdTemporar: Int
    let role: Int
    let jobType: String
    let defaultLanguage: String
    let verificationCode: String?
    let lastSigninAt: String?
    let isActiveNotificationEmail: Int
    let isActiveNotificationInApp: Int
    let timeZone: String
    let defaultTenantId: String?
    let defaultOrganizationId: String?
    let organizationList: [OrganizationInfoDTO]?
    let updatedBy: String?
    let updatedAt: String?
    let deleted: Bool
    let id: String
}

struct OrganizationInfoDTO: Decodable {
    let organizationId: String
    let organizationName: String
    let tenantId: String
    let tenantName: String
}

// MARK: - DTO to Domain Mappers
extension LoginResponseDTO {
    func toDomainUser() -> User? {
        guard let currentUser = currentUser else { return nil }
        
        // Parse lastSigninAt date
        var lastSignin: Date?
        if let signinString = currentUser.lastSigninAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            lastSignin = formatter.date(from: signinString)
        }
        
        // Map organizations
        let organizations = currentUser.organizationList?.map { org in
            UserOrganization(
                id: org.organizationId,
                name: org.organizationName,
                tenantId: org.tenantId,
                tenantName: org.tenantName
            )
        } ?? []
        
        return User(
            id: currentUser.id,
            name: currentUser.name,
            userName: currentUser.userName,
            email: currentUser.email,
            role: currentUser.role,
            jobType: currentUser.jobType,
            defaultLanguage: currentUser.defaultLanguage,
            timeZone: currentUser.timeZone,
            isActive: currentUser.active == 1,
            isEmailConfirmed: currentUser.emailConfirmed == 1,
            isPwdTemporary: currentUser.pwdTemporar == 1,
            organizationId: currentUser.defaultOrganizationId,
            tenantId: currentUser.defaultTenantId,
            organizations: organizations,
            lastSigninAt: lastSignin,
            isNotificationEmailActive: currentUser.isActiveNotificationEmail == 1,
            isNotificationInAppActive: currentUser.isActiveNotificationInApp == 1
        )
    }
    
    func toDomainToken() -> AuthToken? {
        guard let token = token else { return nil }
        
        return AuthToken(
            accessToken: token,
            refreshToken: nil, // API doesn't provide refresh token yet
            expiresAt: nil // API doesn't provide expiration yet
        )
    }
}

extension LoginCredentials {
    func toDTO() -> LoginRequestDTO {
        return LoginRequestDTO(
            email: email,
            password: password,
            isMobile: true
        )
    }
} 