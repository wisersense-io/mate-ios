import Foundation
import SwiftUI

// MARK: - Dashboard View Model
@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var chartData: [DonutChartData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDateFilter: DashboardDateType = DateFilterManager.defaultDashboardFilter
    @Published var availableFilters: [DashboardDateFilter] = DateFilterManager.availableFilters
    
    // System Alarm Trend Properties
    @Published var systemAlarmTrendData: SystemAlarmTrendData?
    @Published var isSystemAlarmTrendLoading = false
    @Published var systemAlarmTrendError: String?
    
    // System Health Score Trend Properties
    @Published var systemHealthScoreTrendData: [HealthScoreTrendItem] = []
    @Published var isSystemHealthScoreTrendLoading = false
    @Published var systemHealthScoreTrendError: String?
    
    // MARK: - Dependencies
    private let dashboardUseCase: DashboardUseCaseProtocol
    private let organizationUseCase: OrganizationUseCaseProtocol
    private var lastUsedOrganizationId: String?
    
    // MARK: - Initialization
    init(dashboardUseCase: DashboardUseCaseProtocol, 
         organizationUseCase: OrganizationUseCaseProtocol = DIContainer.shared.makeOrganizationUseCase()) {
        self.dashboardUseCase = dashboardUseCase
        self.organizationUseCase = organizationUseCase
    }
    
    // MARK: - Public Methods
    func loadChartData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dashboardChartData = try await dashboardUseCase.getChartDistribution(dateType: selectedDateFilter)
            
            // Convert to DonutChartData
            let donutChartData = dashboardChartData.map { $0.toDonutChartData() }
            
            self.chartData = donutChartData
            print("✅ DashboardViewModel: Successfully loaded \(donutChartData.count) charts")
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ DashboardViewModel: Error loading chart data: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshData() async {
        // Load all chart data in parallel
        async let _ = loadChartData()
        async let _ = loadSystemAlarmTrend()
        async let _ = loadSystemHealthScoreTrend()
    }
    
    func updateDateFilter(_ dateType: DashboardDateType) async {
        guard selectedDateFilter != dateType else { return }
        
        selectedDateFilter = dateType
        
        await refreshData()
    }
    
    func getLocalizedFilterTitle(_ dateType: DashboardDateType) -> String {
        return DateFilterManager.getLocalizedTitle(for: dateType)
    }
    
    func loadSystemAlarmTrend() async {
        isSystemAlarmTrendLoading = true
        systemAlarmTrendError = nil
        
        do {
            // 15 günden fazla veri istediğinde haftalık çözünürlük kullan
            let resolutionType: DashboardDateResolutionType = selectedDateFilter.rawValue >= 4 ? .weekly : .daily
            
            let trendData = try await dashboardUseCase.getSystemAlarmTrend(
                dateType: selectedDateFilter,
                resolutionType: resolutionType
            )
            
            self.systemAlarmTrendData = trendData
            print("✅ DashboardViewModel: Successfully loaded system alarm trend with \(resolutionType) resolution")
            
        } catch {
            self.systemAlarmTrendError = error.localizedDescription
            print("❌ DashboardViewModel: Error loading system alarm trend: \(error)")
        }
        
        isSystemAlarmTrendLoading = false
    }
    
    func refreshSystemAlarmTrend() async {
        await loadSystemAlarmTrend()
    }
    
    func loadSystemHealthScoreTrend() async {
        isSystemHealthScoreTrendLoading = true
        systemHealthScoreTrendError = nil
        
        do {
            // 15 günden fazla veri istediğinde haftalık çözünürlük kullan
            let resolutionType: DashboardDateResolutionType = selectedDateFilter.rawValue >= 4 ? .weekly : .daily
            
            let trendData = try await dashboardUseCase.getSystemHealthScoreTrend(
                dateType: selectedDateFilter,
                resolutionType: resolutionType
            )
            
            self.systemHealthScoreTrendData = trendData
            print("✅ DashboardViewModel: Successfully loaded system health score trend with \(resolutionType) resolution")
            
        } catch {
            self.systemHealthScoreTrendError = error.localizedDescription
            print("❌ DashboardViewModel: Error loading system health score trend: \(error)")
        }
        
        isSystemHealthScoreTrendLoading = false
    }
    
    func refreshSystemHealthScoreTrend() async {
        await loadSystemHealthScoreTrend()
    }
    
    // MARK: - Organization Management
    
    func checkAndRefreshIfOrganizationChanged() async {
        let currentOrganizationId = organizationUseCase.getActiveOrganization()
        
        if currentOrganizationId != lastUsedOrganizationId {
            print("🔄 DashboardViewModel: Organization changed from \(lastUsedOrganizationId ?? "nil") to \(currentOrganizationId ?? "nil")")
            lastUsedOrganizationId = currentOrganizationId
            
            // Refresh all data when organization changes
            await refreshData()
        }
    }
} 
