import SwiftUI


struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?
    @State private var isShowingResetSheet = false
    @State private var rememberMe = false
    
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    enum Field {
        case email, password
    }
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo section
            VStack(spacing: 16) {
                Image(themeManager.isDarkMode ? "logo_white" : "logo_colorful")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                
                // Language dropdown aligned to right
                HStack {
                    Spacer()
                    LanguageDropdown()
                }
            }
            .padding(.top, 30)
            
            VStack(spacing: 16) {
                TextField("email_placeholder".localized(language: localizationManager.currentLanguage), text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .submitLabel(.next)
                    .background(themeManager.currentColors.primaryWorkspaceColor)
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .email)
                    .onSubmit {
                        focusedField = .password
                    }
                
                SecureField("password_placeholder".localized(language: localizationManager.currentLanguage), text: $viewModel.password)
                    .textContentType(.password)
                    .padding()
                    .background(themeManager.currentColors.primaryWorkspaceColor)
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                    )
                    .submitLabel(.done)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        focusedField = nil
                    }
                
                
                
                HStack{
                    RememberMeView(isChecked: $rememberMe, localizationManager: localizationManager, themeManager: themeManager)
                    Spacer()
                    NavigationLink(destination: PasswordResetView(email: viewModel.email)) {
                        Text("forgot_password".localized(language: localizationManager.currentLanguage))
                            .font(.footnote)
                            .foregroundColor(themeManager.currentColors.mainAccentColor)
                    }
                    .buttonStyle(.plain)
                }
                
            }
            .padding(.horizontal)
            
            if let error = viewModel.loginError {
                Text(error)
                    .foregroundColor(themeManager.currentColors.dangerColor)
                    .font(.footnote)
            }
            
            Button(action: {
                Task {
                    await viewModel.login()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentColors.mainAccentNotColor))
                } else {
                    Text("sign_in".localized(language: localizationManager.currentLanguage))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentColors.mainAccentColor)
                        .foregroundColor(themeManager.currentColors.mainAccentNotColor)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            .onChange(of: viewModel.isLoginSuccessful) {
                if viewModel.isLoginSuccessful {
                    NotificationCenter.default.post(name: .userDidLogin, object: nil)
                    viewModel.resetLoginState()
                }
            }
            
            Spacer()
        }
        .padding()
        .background(themeManager.currentColors.mainBgColor)
    }
}

struct RememberMeView: View {
    @Binding var isChecked: Bool
    let localizationManager: LocalizationManager
    let themeManager: ThemeManager

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack(spacing: 8) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? themeManager.currentColors.mainAccentColor : themeManager.currentColors.systemStrokeColor)
                    .imageScale(.medium)

                Text("remember_me".localized(language: localizationManager.currentLanguage))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .font(.footnote)
            }
        }
        .buttonStyle(.plain)
    }
}

/*#Preview {
    LoginView()
}
*/
