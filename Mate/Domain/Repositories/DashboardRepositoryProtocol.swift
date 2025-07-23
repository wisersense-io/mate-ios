import Foundation

// MARK: - Dashboard Repository Protocol
protocol DashboardRepositoryProtocol {
    func fetchChartDistribution(organizationId: String, dateType: DashboardDateType) async throws -> [DashboardChartData]
    func fetchSystemAlarmTrend(organizationId: String, dateType: DashboardDateType, resolutionType: DashboardDateResolutionType) async throws -> SystemAlarmTrendData
    func fetchSystemHealthScoreTrend(organizationId: String, dateType: DashboardDateType, resolutionType: DashboardDateResolutionType) async throws -> [HealthScoreTrendItem]
} 