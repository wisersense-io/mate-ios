import Foundation

@MainActor
class VerificationCodeViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isCodeValid: Bool = false
    @Published var timeRemaining = 300
    
    private var timer: Timer?
    private let verificationCodeUseCase: VerificationCodeUseCaseProtocol
    
    init(verificationCodeUseCase: VerificationCodeUseCaseProtocol = DIContainer.shared.makeVerificationCodeUseCase()) {
        self.verificationCodeUseCase = verificationCodeUseCase
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            Task { @MainActor in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func verifyCode(for email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await verificationCodeUseCase.execute(email: email, code: code)
            isCodeValid = result
            
            if !result {
                errorMessage = "verification_code_error".localized()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    deinit {
        timer?.invalidate()
    }
}
