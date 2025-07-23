import SwiftUI

struct SystemDetailView: View {
    let system: System
    let isAlive: Bool
    let isDeviceConnected: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var viewModel: SystemDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(system: System, isAlive: Bool = false, isDeviceConnected: Bool = false) {
        self.system = system
        self.isAlive = isAlive
        self.isDeviceConnected = isDeviceConnected
        
        let container = DIContainer.shared
        self._viewModel = StateObject(wrappedValue: SystemDetailViewModel(
            system: system,
            systemUseCase: container.systemUseCaseInstance,
            organizationUseCase: container.organizationUseCaseInstance
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // System Icon and Status (same as SystemCard but without key/description)
                    systemIconSection
                    
                    // Health Score Gauge
                    HealthScoreGaugeWidget(
                        score: system.healthScore,
                        title: "health_score_title".localized(language: localizationManager.currentLanguage)
                    ) {
                        shareHealthScore()
                    }
                    
                    // Divider
                    Divider()
                        .background(themeManager.currentColors.mainBorderColor)
                        .padding(.horizontal, 16)
                    
                    // Health Score Trend Chart (SimpleLineChart from HomeView)
                    if viewModel.isHealthScoreTrendLoading {
                        ProgressView("loading_trend_data".localized(language: localizationManager.currentLanguage))
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(themeManager.currentColors.mainBgColor)
                                    .shadow(color: themeManager.currentColors.mainBorderColor.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                    } else if let errorMessage = viewModel.healthScoreTrendError {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48))
                                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                            
                            Text(errorMessage)
                                .font(.body)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button("Tekrar Dene") {
                                Task {
                                    await viewModel.checkAndRefreshIfOrganizationChanged()
                                    await viewModel.refreshHealthScoreTrend()
                                }
                            }
                            .foregroundColor(themeManager.currentColors.mainAccentColor)
                        }
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
                            trendData: viewModel.simpleLineChartData
                        )
                        .environmentObject(themeManager)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(themeManager.currentColors.primaryWorkspaceColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        // Custom back button
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                        }
                        
                        // System Key and Description
                        VStack(alignment: .leading, spacing: 2) {
                            Text(system.key)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                            
                            Text(system.description)
                                .font(.caption)
                                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Date Filter Menu (same as DashboardView)
                    Menu {
                        ForEach(viewModel.availableFilters, id: \.dateType) { filter in
                            Button(action: {
                                Task {
                                    await viewModel.checkAndRefreshIfOrganizationChanged()
                                    await viewModel.updateDateFilter(filter.dateType)
                                }
                            }) {
                                HStack {
                                    Text(viewModel.getLocalizedFilterTitle(filter.dateType))
                                    if viewModel.selectedDateFilter == filter.dateType {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.getLocalizedFilterTitle(viewModel.selectedDateFilter))
                                .font(.caption)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(themeManager.currentColors.mainBgColor)
                                .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                        )
                    }
                }
            }
            .toolbarBackground(themeManager.currentColors.primaryWorkspaceColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .navigationBarHidden(true)
        .task {
            print("📱 SystemDetailView: Initial task triggered")
            
            // Check if organization changed and refresh if needed
            await viewModel.checkAndRefreshIfOrganizationChanged()
            
            await viewModel.loadHealthScoreTrend()
        }
        .refreshable {
            await viewModel.checkAndRefreshIfOrganizationChanged()
            await viewModel.refreshHealthScoreTrend()
        }
    }
    
    private func shareHealthScore() {
        // Create share content with dynamic health score
        let shareText = "health_score_share_message".localized(language: localizationManager.currentLanguage)
        .replacingOccurrences(of: "{score}", with: String(format: "%.1f", viewModel.gaugeHealthScore))
        
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
    
    // MARK: - System Icon Section
    
    private var systemIconSection: some View {
        VStack(spacing: 12) {
            // SVG Icon (same as SystemCard)
            if let systemInfo = system.parsedInfo {
                SVGView(svgString: systemInfo.icon, size: 120.0)
                    .frame(width: 120, height: 120)
                    .scaledToFit()
                    .environmentObject(themeManager)
            } else {
                // Fallback icon if no SVG
                Image(systemName: "cpu")
                    .font(.system(size: 60))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .frame(width: 120, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.currentColors.primaryWorkspaceColor.opacity(0.3))
                    )
            }
            
            // Status indicators (same as SystemCard)
            HStack {
                // Left side - Alarm and Diagnosis icons
                HStack(spacing: 8) {
                    // Alarm indicator
                    Image(systemName: "bell")
                        .font(.system(size: 16))
                        .foregroundColor(system.hasAlarm ? .red : themeManager.currentColors.mainTextColor.opacity(0.3))
                    
                    // Diagnosis indicator
                    Image(systemName: "stethoscope")
                        .font(.system(size: 16))
                        .foregroundColor(system.hasDiagnosis ? themeManager.currentColors.mainAccentColor : themeManager.currentColors.mainTextColor.opacity(0.3))
                    
                    // Alive indicator (running state)
                    Image(systemName: "power")
                        .font(.system(size: 16))
                        .foregroundColor(isAlive ? Color.green : themeManager.currentColors.mainTextColor.opacity(0.3))
                }
                
                Spacer()
                
                // Right side - Connection status
                Image(systemName: isDeviceConnected ? "wifi" : "wifi.slash")
                    .font(.system(size: 16))
                    .foregroundColor(isDeviceConnected ? Color.green : Color.red)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(themeManager.currentColors.mainBgColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}
