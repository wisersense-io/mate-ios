import SwiftUI

struct VerificationCodeView: View {
    let email: String
    @StateObject private var viewModel = VerificationCodeViewModel()
    @State private var shouldNavigateToLogin = false
    @State private var showSuccessAlert = false
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 20) {
            Text("verification_code_message".localized(language: localizationManager.currentLanguage))
                .multilineTextAlignment(.center)
                .foregroundColor(themeManager.currentColors.mainTextColor)
            
            CircularCountdownView(currentTime: Double(viewModel.timeRemaining))

            TextField("verification_code_placeholder".localized(language: localizationManager.currentLanguage), text: $viewModel.code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .padding()
                .background(themeManager.currentColors.primaryWorkspaceColor)
                .foregroundColor(themeManager.currentColors.mainTextColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                )

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(themeManager.currentColors.dangerColor)
                    .font(.footnote)
            }

            Button {
                Task {
                    await viewModel.verifyCode(for: email)
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentColors.mainAccentNotColor))
                } else {
                    Text("verify".localized(language: localizationManager.currentLanguage))
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
        .background(themeManager.currentColors.mainBgColor)
        .navigationTitle("verification_code_title".localized(language: localizationManager.currentLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startTimer()
        }
        .onChange(of: viewModel.isCodeValid) {
            if viewModel.isCodeValid {
                print("✅ Kod doğrulandı! Yeni şifre ekranına geçilebilir.")
                showSuccessAlert = true
                // İleri adım için Navigation yapılabilir.
            }
        }
        .alert("success".localized(language: localizationManager.currentLanguage), isPresented: $showSuccessAlert) {
            Button("ok".localized(language: localizationManager.currentLanguage)) {
                shouldNavigateToLogin = true
            }
        } message: {
            Text("verification_success_message".localized(language: localizationManager.currentLanguage))
        }
        .navigationDestination(isPresented: $shouldNavigateToLogin) {
            LoginView()
                .navigationBarBackButtonHidden(true)
        }
    }
}
