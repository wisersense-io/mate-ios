import Foundation

// MARK: - Auth Repository Implementation
class AuthRepository: AuthRepositoryProtocol {
    
    private let networkDataSource: AuthNetworkDataSourceProtocol
    private let tokenStorage: TokenStorageServiceProtocol
    
    init(
        networkDataSource: AuthNetworkDataSourceProtocol,
        tokenStorage: TokenStorageServiceProtocol
    ) {
        self.networkDataSource = networkDataSource
        self.tokenStorage = tokenStorage
    }
    
    func login(credentials: LoginCredentials) async throws -> (user: User, token: AuthToken) {
        let requestDTO = credentials.toDTO()
        let responseDTO = try await networkDataSource.login(request: requestDTO)
        
        // Check for API errors first
        if responseDTO.hasError {
            
            // Handle specific WiserErrorCode values
            switch responseDTO.errorCode {
            case -1: // InvalidUserNameOrPassword
                throw AuthError.invalidCredentials
            case -2: // UserNotActive
                throw AuthError.userInactive
            case -3: // EMailNotConfirmed
                throw AuthError.emailNotConfirmed
            case -4: // UserAppNotFoundOrNotActive
                throw AuthError.userNotFound
            case -5: // TokenNotFound
                throw AuthError.serverError("Token not found", errorCode: responseDTO.errorCode)
            case -6: // RequiredFields
                throw AuthError.serverError("Required fields missing", errorCode: responseDTO.errorCode)
            case -7: // EMailNotValid
                throw AuthError.serverError("Invalid email format", errorCode: responseDTO.errorCode)
            case -8: // InvalidPattern
                throw AuthError.serverError("Invalid data format", errorCode: responseDTO.errorCode)
            case -9: // UserNotFound
                throw AuthError.userNotFound
            case -400: // Exception
                throw AuthError.serverError("Server exception occurred", errorCode: responseDTO.errorCode)
            default:
                // For any other error codes or positive values
                throw AuthError.serverError("Unknown server error", errorCode: responseDTO.errorCode)
            }
        }
        
        // Extract user and token
        guard let user = responseDTO.toDomainUser() else {
            throw AuthError.serverError("User data missing", errorCode: responseDTO.errorCode)
        }
        
        guard let token = responseDTO.toDomainToken() else {
            throw AuthError.serverError("Token missing", errorCode: responseDTO.errorCode)
        }
        
        return (user: user, token: token)
    }
    
    func forgotPassword(email: String) async throws {
        let requestDTO = ForgotPasswordRequestDTO(
            eMailAddress: email,
            verificationCode: ""
        )
        _ = try await networkDataSource.forgotPassword(request: requestDTO)
    }
    
    func verifyCode(email: String, code: String) async throws -> Bool {
        let requestDTO = ForgotPasswordRequestDTO(
            eMailAddress: email,
            verificationCode: code
        )
        return try await networkDataSource.verifyCode(request: requestDTO)
    }
    
    func saveToken(_ token: AuthToken) throws {
        try tokenStorage.saveToken(token)
    }
    
    func getStoredToken() -> AuthToken? {
        return tokenStorage.getToken()
    }
    
    func clearToken() {
        tokenStorage.clearToken()
    }
    
    func isLoggedIn() -> Bool {
        return tokenStorage.isTokenValid()
    }
    
    // MARK: - FCM Token Registration
    
    func registerFCMToken(_ token: String, _ userId: String) async throws {
        try await networkDataSource.registerFCMToken(token, userId)
    }
} 
