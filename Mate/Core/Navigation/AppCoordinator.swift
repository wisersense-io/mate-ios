import SwiftUI
import Combine

// MARK: - App Coordinator
@MainActor
class AppCoordinator: ObservableObject {
    
    @Published var isUserLoggedIn: Bool = false
    @Published var isLoading: Bool = true
    
    private let diContainer: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(diContainer: DIContainer = DIContainer.shared) {
        self.diContainer = diContainer
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        isLoading = true
        
        // Check if user has valid token and session
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let hasValidToken = self?.diContainer.isUserLoggedIn() ?? false
            let hasUserSession = UserSessionManager.shared.isLoggedIn
            
            self?.isUserLoggedIn = hasValidToken && hasUserSession
            self?.isLoading = false
        }
    }
    
    func userDidLogin() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isUserLoggedIn = true
        }
    }
    
    func userDidLogout() {
        diContainer.logout()
        withAnimation(.easeInOut(duration: 0.3)) {
            isUserLoggedIn = false
        }
    }
}

// MARK: - App Root View
struct AppRootView: View {
    @StateObject private var coordinator = AppCoordinator()
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if coordinator.isLoading {
                // Splash/Loading Screen
                SplashView()
            } else if coordinator.isUserLoggedIn {
                // Main App with Tabs
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            } else {
                // Authentication Flow
                NavigationStack {
                    LoginView()
                        .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { _ in
                            coordinator.userDidLogin()
                        }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .trailing)
                ))
            }
        }
        .environmentObject(coordinator)
        .animation(.easeInOut(duration: 0.4), value: coordinator.isUserLoggedIn)
        .animation(.easeInOut(duration: 0.3), value: coordinator.isLoading)
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
            coordinator.userDidLogout()
        }
        .onChange(of: colorScheme) { _, newColorScheme in
            // Update theme when system color scheme changes
            themeManager.updateSystemTheme()
        }
    }
}

// MARK: - Splash View
struct SplashView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(themeManager.isDarkMode ? "logo_white" : "logo_colorful")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentColors.mainAccentColor))
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.currentColors.mainBgColor)
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
} 