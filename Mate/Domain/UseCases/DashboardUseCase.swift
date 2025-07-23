import Foundation

// MARK: - Dashboard Use Case Protocol
protocol DashboardUseCaseProtocol {
    func getChartDistribution(dateType: DashboardDateType) async throws -> [DashboardChartData]
    func getSystemAlarmTrend(dateType: DashboardDateType, resolutionType: DashboardDateResolutionType) async throws -> SystemAlarmTrendData
    func getSystemHealthScoreTrend(dateType: DashboardDateType, resolutionType: DashboardDateResolutionType) async throws -> [HealthScoreTrendItem]
}

// MARK: - Dashboard Use Case Implementation
class DashboardUseCase: DashboardUseCaseProtocol {
    
    private let dashboardRepository: DashboardRepositoryProtocol
    private let organizationUseCase: OrganizationUseCaseProtocol
    
    init(dashboardRepository: DashboardRepositoryProtocol, organizationUseCase: OrganizationUseCaseProtocol) {
        self.dashboardRepository = dashboardRepository
        self.organizationUseCase = organizationUseCase
    }
    
    func getChartDistribution(dateType: DashboardDateType = .last7Days) async throws -> [DashboardChartData] {
        // Get organization ID from OrganizationUseCase (priority: selected > user default)
        guard let organizationId = organizationUseCase.getActiveOrganization() else {
            throw APIError.invalidResponse("Organization ID not found. Please select an organization.")
        }
        
        print("🎯 DashboardUseCase: Getting chart distribution for organizationId: \(organizationId), dateType: \(dateType)")
        
        do {
            let chartData = try await dashboardRepository.fetchChartDistribution(
                organizationId: organizationId,
                dateType: dateType
            )
            
            print("✅ DashboardUseCase: Successfully fetched \(chartData.count) charts")
            return chartData
            
        } catch {
            print("❌ DashboardUseCase: Error getting chart distribution: \(error)")
            throw error
        }
    }
    
    func getSystemAlarmTrend(dateType: DashboardDateType = .last7Days, resolutionType: DashboardDateResolutionType = .daily) async throws -> SystemAlarmTrendData {
        // Get organization ID from OrganizationUseCase (priority: selected > user default)
        guard let organizationId = organizationUseCase.getActiveOrganization() else {
            throw APIError.invalidResponse("Organization ID not found. Please select an organization.")
        }
        
        print("🎯 DashboardUseCase: Getting system alarm trend for organizationId: \(organizationId), dateType: \(dateType), resolutionType: \(resolutionType)")
        
        do {
            let trendData = try await dashboardRepository.fetchSystemAlarmTrend(
                organizationId: organizationId,
                dateType: dateType,
                resolutionType: resolutionType
            )
            
            print("✅ DashboardUseCase: Successfully fetched system alarm trend")
            return trendData
            
        } catch {
            print("❌ DashboardUseCase: Error getting system alarm trend: \(error)")
            throw error
        }
    }
    
    func getSystemHealthScoreTrend(dateType: DashboardDateType = .last7Days, resolutionType: DashboardDateResolutionType = .daily) async throws -> [HealthScoreTrendItem] {
        // Get organization ID from OrganizationUseCase (priority: selected > user default)
        guard let organizationId = organizationUseCase.getActiveOrganization() else {
            throw APIError.invalidResponse("Organization ID not found. Please select an organization.")
        }
        
        print("🎯 DashboardUseCase: Getting system health score trend for organizationId: \(organizationId), dateType: \(dateType), resolutionType: \(resolutionType)")
        
        do {
            let trendData = try await dashboardRepository.fetchSystemHealthScoreTrend(
                organizationId: organizationId,
                dateType: dateType,
                resolutionType: resolutionType
            )
            
            print("✅ DashboardUseCase: Successfully fetched system health score trend")
            return trendData
            
        } catch {
            print("❌ DashboardUseCase: Error getting system health score trend: \(error)")
            throw error
        }
    }
} 