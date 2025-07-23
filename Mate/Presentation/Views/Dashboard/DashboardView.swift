import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var viewModel: DashboardViewModel
    
    init() {
        let dashboardUseCase = DIContainer.shared.makeDashboardUseCase()
        self._viewModel = StateObject(wrappedValue: DashboardViewModel(dashboardUseCase: dashboardUseCase))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isLoading {
                        // Loading state
                        ProgressView("loading".localized())
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .foregroundColor(themeManager.currentColors.mainTextColor)
                    } else if let errorMessage = viewModel.errorMessage {
                        // Error state
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
                                    await viewModel.refreshData()
                                }
                            }
                            .foregroundColor(themeManager.currentColors.mainAccentColor)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        // Success state - Horizontal scrollable donut chart widgets
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.chartData) { data in
                                    DonutChart(data: data)
                                        .frame(width: 350)
                                        .environmentObject(themeManager)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // System Alarm Trend Chart
                        if viewModel.isSystemAlarmTrendLoading {
                            ProgressView("loading".localized())
                                .frame(maxWidth: .infinity, minHeight: 300)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                        } else if let systemAlarmTrendError = viewModel.systemAlarmTrendError {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 48))
                                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                                
                                Text(systemAlarmTrendError)
                                    .font(.body)
                                    .foregroundColor(themeManager.currentColors.mainTextColor)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                
                                Button("Tekrar Dene") {
                                    Task {
                                        await viewModel.checkAndRefreshIfOrganizationChanged()
                                        await viewModel.refreshSystemAlarmTrend()
                                    }
                                }
                                .foregroundColor(themeManager.currentColors.mainAccentColor)
                            }
                            .frame(maxWidth: .infinity, minHeight: 300)
                        } else if let systemAlarmTrendData = viewModel.systemAlarmTrendData {
                            MultiLineChart(
                                title: systemAlarmTrendData.titleKey.localized(language: localizationManager.currentLanguage),
                                trendData: systemAlarmTrendData
                            )
                            .environmentObject(themeManager)
                            .environmentObject(localizationManager)
                        }
                        
                        // System Health Score Trend Chart
                        if viewModel.isSystemHealthScoreTrendLoading {
                            ProgressView("loading".localized())
                                .frame(maxWidth: .infinity, minHeight: 300)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                        } else if let systemHealthScoreTrendError = viewModel.systemHealthScoreTrendError {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 48))
                                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                                
                                Text(systemHealthScoreTrendError)
                                    .font(.body)
                                    .foregroundColor(themeManager.currentColors.mainTextColor)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                
                                Button("Tekrar Dene") {
                                    Task {
                                        await viewModel.checkAndRefreshIfOrganizationChanged()
                                        await viewModel.refreshSystemHealthScoreTrend()
                                    }
                                }
                                .foregroundColor(themeManager.currentColors.mainAccentColor)
                            }
                            .frame(maxWidth: .infinity, minHeight: 300)
                        } else if !viewModel.systemHealthScoreTrendData.isEmpty {
                            SimpleLineChart(
                                title: "key_health_score_trend_of_systems".localized(language: localizationManager.currentLanguage),
                                trendData: viewModel.systemHealthScoreTrendData
                            )
                            .environmentObject(themeManager)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .background(themeManager.currentColors.primaryWorkspaceColor)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // Mate Logo
                    Image(themeManager.isDarkMode ? "dark_mate_logo" : "light_mate_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    // Date Filter
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
            .task {
                print("📱 DashboardView: Initial task triggered")
                
                // Check if organization changed and refresh if needed
                await viewModel.checkAndRefreshIfOrganizationChanged()
                
                await viewModel.refreshData()
            }
        }
    }
}



#Preview {
    DashboardView()
        .environmentObject(ThemeManager.shared)
}
