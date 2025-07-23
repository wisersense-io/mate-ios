import Foundation

// MARK: - User Session Manager
class UserSessionManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var currentOrganizationId: String?
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "current_user"
    private let organizationIdKey = "current_organization_id"
    
    static let shared = UserSessionManager()
    
    private init() {
        loadUserSession()
    }
    
    func setUser(_ user: User) {
        currentUser = user
        isLoggedIn = true
        
        // Set organization ID based on logic: defaultOrganizationId ?? first organization id
        let organizationId = user.organizationId ?? user.organizations.first?.id
        setCurrentOrganizationId(organizationId)
        
        saveUserSession()
    }
    
    func clearUser() {
        currentUser = nil
        isLoggedIn = false
        currentOrganizationId = nil
        userDefaults.removeObject(forKey: userKey)
        userDefaults.removeObject(forKey: organizationIdKey)
    }
    
    func setCurrentOrganizationId(_ organizationId: String?) {
        currentOrganizationId = organizationId
        if let organizationId = organizationId {
            userDefaults.set(organizationId, forKey: organizationIdKey)
        } else {
            userDefaults.removeObject(forKey: organizationIdKey)
        }
    }
    
    func getCurrentOrganizationId() -> String? {
        print("🏢 UserSessionManager: getCurrentOrganizationId called")
        print("   - currentOrganizationId: \(currentOrganizationId ?? "nil")")
        print("   - UserDefaults organizationId: \(userDefaults.string(forKey: organizationIdKey) ?? "nil")")
        print("   - currentUser available: \(currentUser != nil)")
        
        // If currentOrganizationId is nil but we have a user, try to reload it
        if currentOrganizationId == nil, let user = currentUser {
            print("🔄 Attempting to reload organization ID from user data...")
            let orgId = user.organizationId ?? user.organizations.first?.id
            setCurrentOrganizationId(orgId)
            print("   - Reloaded organizationId: \(orgId ?? "still nil")")
        }
        
        return currentOrganizationId
    }
    
    private func saveUserSession() {
        guard let user = currentUser else { return }
        
        if let encoded = try? JSONEncoder().encode(UserDTO.fromDomain(user)) {
            userDefaults.set(encoded, forKey: userKey)
        }
    }
    
    private func loadUserSession() {
        guard let data = userDefaults.data(forKey: userKey),
              let userDTO = try? JSONDecoder().decode(UserDTO.self, from: data) else {
            return
        }
        
        currentUser = userDTO.toDomain()
        isLoggedIn = true
        
        // Load organization ID
        currentOrganizationId = userDefaults.string(forKey: organizationIdKey)
    }
}

// MARK: - User DTO for Storage
struct UserDTO: Codable {
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
    let organizations: [OrganizationDTO]
    let lastSigninAt: Date?
    let isNotificationEmailActive: Bool
    let isNotificationInAppActive: Bool
}

struct OrganizationDTO: Codable {
    let id: String
    let name: String
    let tenantId: String
    let tenantName: String
}

// MARK: - Domain to DTO Mappers
extension UserDTO {
    static func fromDomain(_ user: User) -> UserDTO {
        return UserDTO(
            id: user.id,
            name: user.name,
            userName: user.userName,
            email: user.email,
            role: user.role,
            jobType: user.jobType,
            defaultLanguage: user.defaultLanguage,
            timeZone: user.timeZone,
            isActive: user.isActive,
            isEmailConfirmed: user.isEmailConfirmed,
            isPwdTemporary: user.isPwdTemporary,
            organizationId: user.organizationId,
            tenantId: user.tenantId,
            organizations: user.organizations.map { OrganizationDTO.fromDomain($0) },
            lastSigninAt: user.lastSigninAt,
            isNotificationEmailActive: user.isNotificationEmailActive,
            isNotificationInAppActive: user.isNotificationInAppActive
        )
    }
    
    func toDomain() -> User {
        return User(
            id: id,
            name: name,
            userName: userName,
            email: email,
            role: role,
            jobType: jobType,
            defaultLanguage: defaultLanguage,
            timeZone: timeZone,
            isActive: isActive,
            isEmailConfirmed: isEmailConfirmed,
            isPwdTemporary: isPwdTemporary,
            organizationId: organizationId,
            tenantId: tenantId,
            organizations: organizations.map { $0.toDomain() },
            lastSigninAt: lastSigninAt,
            isNotificationEmailActive: isNotificationEmailActive,
            isNotificationInAppActive: isNotificationInAppActive
        )
    }
}

extension OrganizationDTO {
    static func fromDomain(_ org: UserOrganization) -> OrganizationDTO {
        return OrganizationDTO(
            id: org.id,
            name: org.name,
            tenantId: org.tenantId,
            tenantName: org.tenantName
        )
    }
    
    func toDomain() -> UserOrganization {
        return UserOrganization(
            id: id,
            name: name,
            tenantId: tenantId,
            tenantName: tenantName
        )
    }
} 