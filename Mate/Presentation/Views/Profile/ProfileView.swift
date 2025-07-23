import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var diContainer = DIContainer.shared
    @StateObject private var userSession = UserSessionManager.shared
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(themeManager.currentColors.mainAccentColor)
                        
                        if let user = userSession.currentUser {
                            VStack(spacing: 6) {
                                Text(user.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(themeManager.currentColors.mainTextColor)
                                
                                Text("@\(user.userName)")
                                    .font(.subheadline)
                                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                                
                                if let org = user.organizations.first {
                                    Text(org.name)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(themeManager.currentColors.mainAccentColor.opacity(0.1))
                                        .foregroundColor(themeManager.currentColors.mainAccentColor)
                                        .cornerRadius(4)
                                }
                            }
                        } else {
                            Text("profile_title".localized(language: localizationManager.currentLanguage))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                        }
                        
                        if diContainer.getCurrentToken() != nil {
                            Text("profile_logged_in".localized(language: localizationManager.currentLanguage))
                                .font(.caption)
                                .foregroundColor(themeManager.currentColors.successColor)
                        }
                    }
                    
                    // Settings Options
                    VStack(spacing: 12) {
                        // Theme Selection
                        Button(action: {
                            viewModel.showThemeSelection = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "paintbrush")
                                    .font(.title3)
                                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                                    .frame(width: 24, height: 24)
                                
                                Text("theme".localized(language: localizationManager.currentLanguage))
                                    .font(.body)
                                    .foregroundColor(themeManager.currentColors.mainTextColor)
                                
                                Spacer()
                                
                                Text(viewModel.getThemeDisplayName(themeManager.currentMode, language: localizationManager.currentLanguage))
                                    .font(.caption)
                                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(themeManager.currentColors.systemStrokeColor.opacity(0.5))
                                        }
            .padding()
            .background(themeManager.currentColors.mainBgColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Language Selection
                        Button(action: {
                            viewModel.showLanguageSelection = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "globe")
                                    .font(.title3)
                                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                                    .frame(width: 24, height: 24)
                                
                                Text("language".localized(language: localizationManager.currentLanguage))
                                    .font(.body)
                                    .foregroundColor(themeManager.currentColors.mainTextColor)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text(localizationManager.currentLanguage.flag)
                                        .font(.caption)
                                    Text(localizationManager.currentLanguage.displayName)
                                        .font(.caption)
                                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                                }
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(themeManager.currentColors.systemStrokeColor.opacity(0.5))
                            }
                            .padding()
                            .background(themeManager.currentColors.mainBgColor)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Change Password
                        ProfileOptionRow(
                            icon: "lock.shield",
                            title: "change_password".localized(language: localizationManager.currentLanguage),
                            action: {
                                viewModel.showChangePasswordSheet = true
                            }
                        )
                        
                        // Privacy Policy
                        ProfileOptionRow(
                            icon: "hand.raised",
                            title: "privacy_policy".localized(language: localizationManager.currentLanguage),
                            action: {
                                if let url = viewModel.getPrivacyPolicyURL(for: localizationManager.currentLanguage) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        
                        // Logout
                        ProfileOptionRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "logout".localized(language: localizationManager.currentLanguage),
                            isDestructive: true,
                            action: {
                                viewModel.showLogoutConfirmationDialog()
                            }
                        )
                    }
                    .padding(.top, 20)
                    
                    // Powered by Fizix
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            if localizationManager.currentLanguage == .english {
                                Text("powered_by".localized(language: localizationManager.currentLanguage))
                                    .font(.caption)
                                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                                
                                Image(themeManager.isDarkMode ? "fizix_logo_white" : "fizix_logo_colorful")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                            } else {
                                Image(themeManager.isDarkMode ? "fizix_logo_white" : "fizix_logo_colorful")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                                
                                Text("powered_by".localized(language: localizationManager.currentLanguage))
                                    .font(.caption)
                                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(themeManager.currentColors.primaryWorkspaceColor)
            .toolbarBackground(themeManager.currentColors.primaryWorkspaceColor, for: .automatic)
            .toolbarBackground(.visible, for: .automatic)
        }
        .sheet(isPresented: $viewModel.showChangePasswordSheet) {
            ChangePasswordView(viewModel: viewModel)
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
        }
        .sheet(isPresented: $viewModel.showThemeSelection) {
            ThemeSelectionView()
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
        }
        .sheet(isPresented: $viewModel.showLanguageSelection) {
            LanguageSelectionView()
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
        }
        .alert("logout_confirmation".localized(language: localizationManager.currentLanguage), isPresented: $viewModel.showLogoutConfirmation) {
            Button("cancel".localized(language: localizationManager.currentLanguage), role: .cancel) {}
            Button("logout".localized(language: localizationManager.currentLanguage), role: .destructive) {
                viewModel.performLogout()
            }
        } message: {
            Text("logout_confirmation_message".localized(language: localizationManager.currentLanguage))
        }
        .alert("password_changed_successfully".localized(language: localizationManager.currentLanguage), isPresented: $viewModel.showPasswordChangeSuccess) {
            Button("ok".localized(language: localizationManager.currentLanguage), role: .cancel) {}
        }
    }
}

// MARK: - Profile Option Row Component
struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let isDestructive: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    init(icon: String, title: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? themeManager.currentColors.dangerColor : themeManager.currentColors.mainAccentColor)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? themeManager.currentColors.dangerColor : themeManager.currentColors.mainTextColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(themeManager.currentColors.systemStrokeColor.opacity(0.5))
            }
                                        .padding()
                            .background(themeManager.currentColors.mainBgColor)
                            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(LocalizationManager())
} 
