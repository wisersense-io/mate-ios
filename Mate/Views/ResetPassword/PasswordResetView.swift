import SwiftUI

struct PasswordResetView: View {
    @StateObject private var viewModel = PasswordResetViewModel()
    @FocusState private var isEmailFocused: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var email: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 100)

                    TextField("email_placeholder".localized(language: localizationManager.currentLanguage), text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .submitLabel(.done)
                        .padding()
                        .background(themeManager.currentColors.primaryWorkspaceColor)
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                        )
                        .focused($isEmailFocused)

                    Text("password_reset_message".localized(language: localizationManager.currentLanguage))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(themeManager.currentColors.dangerColor)
                            .font(.footnote)
                    }

                    Button {
                        Task {
                            await viewModel.submitResetRequest()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentColors.mainAccentNotColor))
                        } else {
                            Text("send_reset_code".localized(language: localizationManager.currentLanguage))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.currentColors.mainAccentColor)
                    .foregroundColor(themeManager.currentColors.mainAccentNotColor)
                    .cornerRadius(8)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("password_reset_title".localized(language: localizationManager.currentLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .background(themeManager.currentColors.mainBgColor)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("back".localized(language: localizationManager.currentLanguage)) {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                }
            }
            .onAppear {
                viewModel.email = email
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isEmailFocused = true
                }
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToCodeScreen) {
                VerificationCodeView(email: viewModel.email)
            }
        }
    }
}

