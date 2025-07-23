import SwiftUI
import Combine

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Tab 1: Dashboard/Home
                HomeView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("home".localized(language: localizationManager.currentLanguage))
                    }
                    .tag(0)
                
                // Tab 2: Projects
                DashboardView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "folder.fill" : "folder")
                        Text("dashboard".localized(language: localizationManager.currentLanguage))
                    }
                    .tag(1)
                
                // Tab 3: Analytics
                OrganizationView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                        Text("organization".localized(language: localizationManager.currentLanguage))
                    }
                    .tag(2)
                
                // Tab 4: Systems (Farklı Icon)
                SystemsView()
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "cpu.fill" : "cpu")
                        Text("systems".localized(language: localizationManager.currentLanguage))
                    }
                    .tag(3)
                
                // Tab 5: Profile
                ProfileView()
                    .tabItem {
                        Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                        Text("profile".localized(language: localizationManager.currentLanguage))
                    }
                    .tag(4)
            }
            .accentColor(themeManager.currentColors.mainAccentColor)
        }
        .background(themeManager.currentColors.primaryWorkspaceColor)
        .onAppear {
            updateTabBarAppearance()
        }
        // ✅ KÖKLÜ ÇÖZÜM: ThemeManager'daki herhangi bir değişikliği yakala
        .onReceive(themeManager.objectWillChange) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                updateTabBarAppearance()
            }
        }
    }
    
    private func updateTabBarAppearance() {
        // ✅ KÖKLÜ ÇÖZÜM: Direct UITabBar güncelleme
        DispatchQueue.main.async {
            // 1. Yeni appearance oluştur
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            // 2. Background
            appearance.backgroundColor = UIColor(themeManager.currentColors.primaryWorkspaceColor)
            
            // 3. Selected state
            let selectedColor = UIColor(themeManager.currentColors.mainAccentColor)
            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
            appearance.compactInlineLayoutAppearance.selected.iconColor = selectedColor
            appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
            
            // 4. Normal state  
            let normalColor = UIColor(themeManager.currentColors.mainTextColor.opacity(0.6))
            appearance.stackedLayoutAppearance.normal.iconColor = normalColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
            appearance.compactInlineLayoutAppearance.normal.iconColor = normalColor
            appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
            
            // 5. Global appearance ayarla
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // 6. ✅ MEVCUT TAB BAR'LARI ZORLA GÜNCELLE
            self.updateExistingTabBars(with: appearance)
        }
    }
    
    private func updateExistingTabBars(with appearance: UITabBarAppearance) {
        // Tüm window'lardaki tab bar'ları bul ve güncelle
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    self.findAndUpdateTabBars(in: window, with: appearance)
                }
            }
        }
    }
    
    private func findAndUpdateTabBars(in view: UIView, with appearance: UITabBarAppearance) {
        // Recursive olarak tüm subview'larda tab bar'ları bul
        if let tabBar = view as? UITabBar {
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
            // Force layout update
            tabBar.setNeedsLayout()
            tabBar.layoutIfNeeded()
        }
        
        for subview in view.subviews {
            findAndUpdateTabBars(in: subview, with: appearance)
        }
    }
} 
