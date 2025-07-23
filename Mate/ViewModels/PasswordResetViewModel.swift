import Foundation

@MainActor
class PasswordResetViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldNavigateToCodeScreen = false
    
    private let forgotPasswordUseCase: ForgotPasswordUseCaseProtocol
    
    init(forgotPasswordUseCase: ForgotPasswordUseCaseProtocol = DIContainer.shared.makeForgotPasswordUseCase()) {
        self.forgotPasswordUseCase = forgotPasswordUseCase
    }
    
    func submitResetRequest() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await forgotPasswordUseCase.execute(email: email)
            shouldNavigateToCodeScreen = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
