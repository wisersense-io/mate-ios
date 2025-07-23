import SwiftUI

struct ChangePasswordView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field {
        case oldPassword, newPassword, confirmPassword
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 48))
                            .foregroundColor(themeManager.currentColors.mainAccentColor)
                        
                        Text("change_password_title".localized(language: localizationManager.currentLanguage))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.currentColors.mainTextColor)
                    }
                    .padding(.top, 20)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        // Old Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("old_password".localized(language: localizationManager.currentLanguage))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                            
                            SecureField("old_password_placeholder".localized(language: localizationManager.currentLanguage), text: $viewModel.oldPassword)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedField, equals: .oldPassword)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .newPassword
                                }
                        }
                        
                        // New Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("new_password".localized(language: localizationManager.currentLanguage))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                            
                            SecureField("new_password_placeholder".localized(language: localizationManager.currentLanguage), text: $viewModel.newPassword)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedField, equals: .newPassword)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .confirmPassword
                                }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("confirm_password".localized(language: localizationManager.currentLanguage))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                            
                            SecureField("confirm_password_placeholder".localized(language: localizationManager.currentLanguage), text: $viewModel.confirmPassword)
                                .textFieldStyle(.roundedBorder)
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil
                                    Task {
                                        await viewModel.changePassword()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Error Message
                    if let error = viewModel.changePasswordError {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(themeManager.currentColors.dangerColor)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await viewModel.changePassword()
                            }
                        }) {
                            HStack {
                                if viewModel.isChangingPassword {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("update_password".localized(language: localizationManager.currentLanguage))
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(themeManager.currentColors.mainAccentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isChangingPassword || viewModel.oldPassword.isEmpty || viewModel.newPassword.isEmpty || viewModel.confirmPassword.isEmpty)
                        
                        Button(action: {
                            viewModel.closeChangePasswordSheet()
                        }) {
                            Text("cancel".localized(language: localizationManager.currentLanguage))
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(themeManager.currentColors.systemStrokeColor.opacity(0.1))
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .background(themeManager.currentColors.primaryWorkspaceColor)
            .toolbarBackground(themeManager.currentColors.primaryWorkspaceColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarHidden(true)
        }
        .onAppear {
            focusedField = .oldPassword
        }
        .onChange(of: viewModel.showChangePasswordSheet) { _, isShowing in
            if !isShowing {
                dismiss()
            }
        }
    }
}

#Preview {
    ChangePasswordView(viewModel: ProfileViewModel())
        .environmentObject(ThemeManager.shared)
        .environmentObject(LocalizationManager())
} 