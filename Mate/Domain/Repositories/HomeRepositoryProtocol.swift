import Foundation

// MARK: - Home Repository Protocol
protocol HomeRepositoryProtocol {
    func fetchDashboardInfo(organizationId: String) async throws -> HomeDashboardInfo
    func fetchHealthScore(organizationId: String, isWeighted: Bool) async throws -> HealthScore
    func fetchHealthScoreTrend(organizationId: String, dateType: DateType, resolutionType: DateResolutionType) async throws -> HealthScoreTrend
} 