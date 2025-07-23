import SwiftUI

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Horizontal Scrollable Dashboard Stats
                    if homeViewModel.isLoading {
                        ProgressView("loading".localized(language: localizationManager.currentLanguage))
                            .frame(height: 120)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(homeViewModel.dashboardItems, id: \.title) { item in
                                    DashboardCircleCard(
                                        title: item.localizedTitle(language: localizationManager.currentLanguage.rawValue),
                                        value: item.displayValue
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Error Message
                    if let error = homeViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(themeManager.currentColors.dangerColor)
                            .padding()
                            .background(themeManager.currentColors.dangerColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                    // Health Score Gauge Widget
                    if homeViewModel.isHealthScoreLoading {
                        ProgressView("loading_health_score".localized(language: localizationManager.currentLanguage))
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(themeManager.currentColors.mainBgColor)
                                    .shadow(color: themeManager.currentColors.mainBorderColor.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                    } else {
                        HealthScoreGaugeWidget(
                            score: homeViewModel.healthScore,
                            title: "health_score_title".localized(language: localizationManager.currentLanguage)
                        ) {
                            // Share action
                            shareHealthScore()
                        }
                    }
                    
                    // Health Score Error Message
                    if let healthScoreError = homeViewModel.healthScoreError {
                        Text(healthScoreError)
                            .foregroundColor(themeManager.currentColors.dangerColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(themeManager.currentColors.dangerColor.opacity(0.1))
                            .cornerRadius(0)
                    }
                    
                    // Simple Line Chart with API Data
                    if homeViewModel.isTrendLoading {
                        ProgressView("loading_trend_data".localized(language: localizationManager.currentLanguage))
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(themeManager.currentColors.mainBgColor)
                                    .shadow(color: themeManager.currentColors.mainBorderColor.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                    } else {
                        SimpleLineChart(
                            title: "health_score_trend".localized(language: localizationManager.currentLanguage),
                            trendData: homeViewModel.healthScoreTrendData
                        )
                        .environmentObject(themeManager)
                    }
                    
                    // Trend Error Message
                    if let trendError = homeViewModel.trendError {
                        Text(trendError)
                            .foregroundColor(themeManager.currentColors.dangerColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(themeManager.currentColors.dangerColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .background(themeManager.currentColors.primaryWorkspaceColor)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(themeManager.isDarkMode ? "dark_mate_logo" : "light_mate_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                }
            }
            .toolbarBackground(themeManager.currentColors.primaryWorkspaceColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(themeManager.currentColors.primaryWorkspaceColor)
            .refreshable {
                print("🔄 HomeView: Pull-to-refresh triggered")
                
                // Check if organization changed and refresh if needed
                await homeViewModel.checkAndRefreshIfOrganizationChanged()
                
                // Load dashboard data, health score, and trend data in parallel
                async let _ = homeViewModel.loadDashboardData()
                async let _ = homeViewModel.loadHealthScore()
                async let _ = homeViewModel.loadHealthScoreTrend()
            }
        }
        .task {
            print("📱 HomeView: Initial task triggered")
            
            // Check if organization changed and refresh if needed
            await homeViewModel.checkAndRefreshIfOrganizationChanged()
            
            // Load dashboard data, health score, and trend data in parallel on first load
            async let _ = homeViewModel.loadDashboardData()
            async let _ = homeViewModel.loadHealthScore()
            async let _ = homeViewModel.loadHealthScoreTrend()
        }
    }
    
    // MARK: - Helper Functions
    private func shareHealthScore() {
        // Create share content with dynamic health score
        let shareText = "health_score_share_message".localized(language: localizationManager.currentLanguage)
            .replacingOccurrences(of: "{score}", with: String(format: "%.1f", homeViewModel.healthScore))
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // Get the current window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            // For iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityVC, animated: true)
        }
    }
}

struct DashboardCircleCard: View {
    let title: String
    let value: String
    let circleSize: CGFloat = 80
    let strokeWidth: CGFloat = 4
    let spacing: CGFloat = 2 // Stroke ve fill arası boşluk
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Dış stroke
                Circle()
                    .stroke(themeManager.currentColors.mainAccentColor, lineWidth: strokeWidth)
                    .frame(width: circleSize, height: circleSize)
                
                // İç fill
                Circle()
                    .fill(themeManager.currentColors.mainBgColor)
                    .frame(
                        width: circleSize - (strokeWidth) - (spacing * 2),
                        height: circleSize - (strokeWidth) - (spacing * 2)
                    )
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentColors.mainTextColor)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.currentColors.mainTextColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: circleSize)
        }
        .padding(.vertical, 8)
    }
}

/*#Preview {
 DashboardCircleCard(title: "Test", value: "12")
 .environmentObject(ThemeManager.shared)
 }
 */
