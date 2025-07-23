import Foundation
import Combine
import SwiftUI

@MainActor
class SystemDetailViewModel: ObservableObject {
    @Published var system: System
    @Published var healthScoreTrendData: [SystemDetailTrendData] = []
    @Published var isHealthScoreTrendLoading = false
    @Published var healthScoreTrendError: String?
    @Published var selectedDateFilter: DashboardDateType = DateFilterManager.defaultSystemDetailFilter
    
    // Available date filters (ortak kullanım)
    let availableFilters: [DashboardDateFilter] = DateFilterManager.availableFilters
    
    private let systemUseCase: SystemUseCase
    private let organizationUseCase: OrganizationUseCaseProtocol
    private var currentOrganizationId: String?
    
    init(system: System, systemUseCase: SystemUseCase, organizationUseCase: OrganizationUseCaseProtocol) {
        self.system = system
        self.systemUseCase = systemUseCase
        self.organizationUseCase = organizationUseCase
    }
    
    // MARK: - Public Methods
    
    func loadHealthScoreTrend() async {
        guard !isHealthScoreTrendLoading else { return }
        
        isHealthScoreTrendLoading = true
        healthScoreTrendError = nil
        
        do {
            // 1 aylık'tan fazla veriler için haftalık yap
            let apiDateType = DateFilterManager.getAPIDateType(for: selectedDateFilter)
            let isWeekly = DateFilterManager.shouldUseWeeklyResolution(for: selectedDateFilter)
            
            print("📊 SystemDetailViewModel: Loading trend for filter: \(selectedDateFilter) -> API dateType: \(apiDateType) (weekly: \(isWeekly))")
            
            let trendData = try await systemUseCase.getSystemHealthScoreTrend(
                systemId: system.id,
                dateType: apiDateType
            )
            
            healthScoreTrendData = trendData
            print("✅ SystemDetailViewModel: Loaded \(trendData.count) health score trend data points")
            
        } catch {
            healthScoreTrendError = error.localizedDescription
            healthScoreTrendData = []
            print("❌ SystemDetailViewModel: Failed to load health score trend - \(error.localizedDescription)")
        }
        
        isHealthScoreTrendLoading = false
    }
    
    func updateDateFilter(_ dateType: DashboardDateType) async {
        selectedDateFilter = dateType
        await loadHealthScoreTrend()
    }
    
    func refreshHealthScoreTrend() async {
        await loadHealthScoreTrend()
    }
    
    // MARK: - Organization Management
    
    private func getOrganizationId() async -> String? {
        do {
            let selectedOrganization = try await organizationUseCase.getSelectedOrganization()
            return selectedOrganization
        } catch {
            return nil
        }
    }
    
    func checkAndRefreshIfOrganizationChanged() async {
        if let newOrganizationId = await getOrganizationId(),
           newOrganizationId != currentOrganizationId {
            currentOrganizationId = newOrganizationId
            await loadHealthScoreTrend()
        }
    }
    
    // MARK: - Helper Methods
    
    func getLocalizedFilterTitle(_ dateType: DashboardDateType) -> String {
        return DateFilterManager.getLocalizedTitle(for: dateType)
    }
    
    // Get formatted health score (toFixed(2))
    var formattedHealthScore: String {
        return String(format: "%.2f", system.healthScore)
    }
    
    // Get health score for gauge (0-100 range)
    var gaugeHealthScore: Double {
        return max(0, min(100, system.healthScore))
    }
    
    // Convert SystemDetailTrendData to HealthScoreTrendItem for SimpleLineChart
    var simpleLineChartData: [HealthScoreTrendItem] {
        return healthScoreTrendData.toHealthScoreTrendItems()
    }
} 