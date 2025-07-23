import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Password Change State
    @Published var isChangingPassword = false
    @Published var changePasswordError: String?
    @Published var showChangePasswordSheet = false
    @Published var showPasswordChangeSuccess = false
    @Published var showLogoutConfirmation = false
    
    // MARK: - Settings Navigation State
    @Published var showThemeSelection = false
    @Published var showLanguageSelection = false
    
    // MARK: - Password Fields
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    // MARK: - Dependencies
    private let profileUseCase: ProfileUseCaseProtocol
    
    // MARK: - Initialization
    init(profileUseCase: ProfileUseCaseProtocol = DIContainer.shared.makeProfileUseCase()) {
        self.profileUseCase = profileUseCase
    }
    
    // MARK: - Password Change Methods
    func changePassword() async {
        isChangingPassword = true
        changePasswordError = nil
        
        do {
            let success = try await profileUseCase.changePassword(
                oldPassword: oldPassword,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )
            
            if success {
                clearPasswordFields()
                showChangePasswordSheet = false
                showPasswordChangeSuccess = true
                print("✅ Password changed successfully")
            }
        } catch {
            changePasswordError = error.localizedDescription
            print("❌ Password change failed: \(error)")
        }
        
        isChangingPassword = false
    }
    
    func clearPasswordFields() {
        oldPassword = ""
        newPassword = ""
        confirmPassword = ""
        changePasswordError = nil
    }
    
    func closeChangePasswordSheet() {
        showChangePasswordSheet = false
        clearPasswordFields()
    }
    
    // MARK: - Logout Methods
    func showLogoutConfirmationDialog() {
        showLogoutConfirmation = true
    }
    
    func performLogout() {
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
        showLogoutConfirmation = false
    }
    
    // MARK: - Theme Methods
    func getThemeDisplayName(_ mode: ThemeMode, language: Language) -> String {
        switch mode {
        case .system:
            return "system_theme".localized(language: language)
        case .light:
            return "light_theme".localized(language: language)
        case .dark:
            return "dark_theme".localized(language: language)
        }
    }
    
    // MARK: - Privacy Policy URLs
    func getPrivacyPolicyURL(for language: Language) -> URL? {
        switch language {
        case .english:
            return URL(string: "https://fizix.ai/privacy-policy/")
        case .turkish:
            return URL(string: "https://wisersense.com.tr/bilgi-guvenligi-politikasi/")
        }
    }
} 