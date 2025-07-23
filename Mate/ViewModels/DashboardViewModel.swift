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
    
    // MARK: - Task Management
    private var currentTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(dashboardUseCase: DashboardUseCaseProtocol, 
         organizationUseCase: OrganizationUseCaseProtocol = DIContainer.shared.makeOrganizationUseCase()) {
        self.dashboardUseCase = dashboardUseCase
        self.organizationUseCase = organizationUseCase
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    // MARK: - Public Methods
    func loadChartData() async {
        guard !Task.isCancelled else {
            print("🚫 DashboardViewModel: Chart data loading cancelled")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
            let dashboardChartData = try await dashboardUseCase.getChartDistribution(dateType: selectedDateFilter)
            
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
            // Convert to DonutChartData
            let donutChartData = dashboardChartData.map { $0.toDonutChartData() }
            
            self.chartData = donutChartData
            print("✅ DashboardViewModel: Successfully loaded \(donutChartData.count) charts")
            
        } catch {
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
            self.errorMessage = error.localizedDescription
            print("❌ DashboardViewModel: Error loading chart data: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshData() async {
        // Cancel any existing task
        currentTask?.cancel()
        
        // Create new task
        currentTask = Task {
            await performDataRefresh()
        }
        
        await currentTask?.value
    }
    
    private func performDataRefresh() async {
        // Check if task is cancelled
        guard !Task.isCancelled else {
            print("🚫 DashboardViewModel: Data refresh cancelled")
            return
        }
        
        // Load chart data sequentially to avoid race conditions
        await loadChartData()
        
        guard !Task.isCancelled else {
            print("🚫 DashboardViewModel: Data refresh cancelled after chart data")
            return
        }
        
        await loadSystemAlarmTrend()
        
        guard !Task.isCancelled else {
            print("🚫 DashboardViewModel: Data refresh cancelled after alarm trend")
            return
        }
        
        await loadSystemHealthScoreTrend()
        
        print("✅ DashboardViewModel: All data refreshed successfully")
        currentTask = nil
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
        guard !Task.isCancelled else {
            print("🚫 DashboardViewModel: System alarm trend loading cancelled")
            return
        }
        
        isSystemAlarmTrendLoading = true
        systemAlarmTrendError = nil
        
        do {
            guard !Task.isCancelled else {
                isSystemAlarmTrendLoading = false
                return
            }
            
            // 15 günden fazla veri istediğinde haftalık çözünürlük kullan
            let resolutionType: DashboardDateResolutionType = selectedDateFilter.rawValue >= 4 ? .weekly : .daily
            
            let trendData = try await dashboardUseCase.getSystemAlarmTrend(
                dateType: selectedDateFilter,
                resolutionType: resolutionType
            )
            
            guard !Task.isCancelled else {
                isSystemAlarmTrendLoading = false
                return
            }
            
            self.systemAlarmTrendData = trendData
            print("✅ DashboardViewModel: Successfully loaded system alarm trend with \(resolutionType) resolution")
            
        } catch {
            guard !Task.isCancelled else {
                isSystemAlarmTrendLoading = false
                return
            }
            
            self.systemAlarmTrendError = error.localizedDescription
            print("❌ DashboardViewModel: Error loading system alarm trend: \(error)")
        }
        
        isSystemAlarmTrendLoading = false
    }
    
    func refreshSystemAlarmTrend() async {
        await loadSystemAlarmTrend()
    }
    
    func loadSystemHealthScoreTrend() async {
        guard !Task.isCancelled else {
            print("🚫 DashboardViewModel: System health score trend loading cancelled")
            return
        }
        
        isSystemHealthScoreTrendLoading = true
        systemHealthScoreTrendError = nil
        
        do {
            guard !Task.isCancelled else {
                isSystemHealthScoreTrendLoading = false
                return
            }
            
            // 15 günden fazla veri istediğinde haftalık çözünürlük kullan
            let resolutionType: DashboardDateResolutionType = selectedDateFilter.rawValue >= 4 ? .weekly : .daily
            
            let trendData = try await dashboardUseCase.getSystemHealthScoreTrend(
                dateType: selectedDateFilter,
                resolutionType: resolutionType
            )
            
            guard !Task.isCancelled else {
                isSystemHealthScoreTrendLoading = false
                return
            }
            
            self.systemHealthScoreTrendData = trendData
            print("✅ DashboardViewModel: Successfully loaded system health score trend with \(resolutionType) resolution")
            
        } catch {
            guard !Task.isCancelled else {
                isSystemHealthScoreTrendLoading = false
                return
            }
            
            self.systemHealthScoreTrendError = error.localizedDescription
            print("❌ DashboardViewModel: Error loading system health score trend: \(error)")
        }
        
        isSystemHealthScoreTrendLoading = false
    }
    
    func refreshSystemHealthScoreTrend() async {
        await loadSystemHealthScoreTrend()
    }
    
    // MARK: - Organization Management
    
    func checkAndRefreshIfOrganizationChanged() async -> Bool {
        let currentOrganizationId = organizationUseCase.getActiveOrganization()
        
        if currentOrganizationId != lastUsedOrganizationId {
            print("🔄 DashboardViewModel: Organization changed from \(lastUsedOrganizationId ?? "nil") to \(currentOrganizationId ?? "nil")")
            lastUsedOrganizationId = currentOrganizationId
            
            // Refresh all data when organization changes
            await refreshData()
            return true // Data was refreshed
        }
        return false // No refresh needed
    }
} 
