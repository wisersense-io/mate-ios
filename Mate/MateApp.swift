// TODO Firebase issue: Youtube link: https://www.youtube.com/watch?v=-6kb_Sq2lrQ
import SwiftUI

@main
struct MateApp: App {
    @StateObject private var localizationManager = LocalizationManager()
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Configure navigation bar appearance globally
        configureNavigationBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(localizationManager)
                .environmentObject(themeManager)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        // Uygulama aktif hale geldiğinde sistem temasını kontrol et
                        updateThemeBasedOnSystem()
                    }
                }
        }
    }
    
    private func updateThemeBasedOnSystem() {
        // Only update if user is using system mode
        themeManager.updateSystemTheme()
    }
    
    private func configureNavigationBarAppearance() {
        // Configure navigation bar appearance to remove white background during scroll
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // Also configure for iPhone X and newer
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        }
    }
}
