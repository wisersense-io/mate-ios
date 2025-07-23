import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var rememberMe: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var loginError: String?
    @Published var isLoginSuccessful: Bool = false
    
    private let loginUseCase: LoginUseCaseProtocol
    
    init(loginUseCase: LoginUseCaseProtocol = DIContainer.shared.makeLoginUseCase()) {
        self.loginUseCase = loginUseCase
    }
    
    func login() async {
        isLoading = true
        loginError = nil
        
        do {
            let user = try await loginUseCase.execute(email: email, password: password)
            
            print("Login successful for user: \(user.name)")
            print("User ID: \(user.id)")
            
            // Login successful - trigger navigation to main app
            isLoginSuccessful = true
            
        } catch {
            // Map AuthError to localized messages
            if let authError = error as? AuthError {
                switch authError {
                case .invalidCredentials:
                    loginError = NSLocalizedString("invalid_email_password", comment: "")
                case .invalidURL:
                    loginError = NSLocalizedString("invalid_url", comment: "")
                case .invalidResponse:
                    loginError = NSLocalizedString("invalid_response", comment: "")
                case .userNotFound:
                    loginError = NSLocalizedString("user_not_found", comment: "")
                case .userInactive:
                    loginError = NSLocalizedString("user_inactive", comment: "")
                case .emailNotConfirmed:
                    loginError = NSLocalizedString("email_not_confirmed", comment: "")
                case .passwordTemporary:
                    loginError = NSLocalizedString("password_temporary", comment: "")
                case .networkError:
                    loginError = NSLocalizedString("network_error", comment: "")
                case .tokenStorage:
                    loginError = NSLocalizedString("token_storage_error", comment: "")
                case .serverError(let message, let errorCode):
                    // Handle specific server error codes
                    switch errorCode {
                    case -5:
                        loginError = NSLocalizedString("token_not_found", comment: "")
                    case -6:
                        loginError = NSLocalizedString("required_fields_missing", comment: "")
                    case -7:
                        loginError = NSLocalizedString("invalid_email_format", comment: "")
                    case -8:
                        loginError = NSLocalizedString("invalid_data_format", comment: "")
                    case -400:
                        loginError = NSLocalizedString("server_exception", comment: "")
                    default:
                        loginError = message.isEmpty ? NSLocalizedString("unknown_error", comment: "") : message
                    }
                case .unknownError(let errorCode):
                    loginError = NSLocalizedString("unknown_error_code", comment: "") + " (\(errorCode))"
                }
            } else {
                loginError = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    func resetLoginState() {
        isLoginSuccessful = false
        loginError = nil
    }
}
