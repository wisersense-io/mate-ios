import Foundation

// MARK: - Home Use Case Protocol
protocol HomeUseCaseProtocol {
    func getDashboardInfo() async throws -> HomeDashboardInfo
    func getHealthScore() async throws -> HealthScore
    func getHealthScoreTrend() async throws -> HealthScoreTrend
}

// MARK: - Home Use Case Implementation
class HomeUseCase: HomeUseCaseProtocol {
    private let homeRepository: HomeRepositoryProtocol
    private let organizationUseCase: OrganizationUseCaseProtocol
    
    init(homeRepository: HomeRepositoryProtocol, organizationUseCase: OrganizationUseCaseProtocol) {
        self.homeRepository = homeRepository
        self.organizationUseCase = organizationUseCase
    }
    
    func getDashboardInfo() async throws -> HomeDashboardInfo {
        // Get organization ID from OrganizationUseCase (priority: selected > user default)
        guard let organizationId = organizationUseCase.getActiveOrganization() else {
            throw APIError.invalidResponse("Organization ID not found. Please select an organization.")
        }
        
        return try await homeRepository.fetchDashboardInfo(organizationId: organizationId)
    }
    
    func getHealthScore() async throws -> HealthScore {
        // Get organization ID from OrganizationUseCase (priority: selected > user default)
        guard let organizationId = organizationUseCase.getActiveOrganization() else {
            throw APIError.invalidResponse("Organization ID not found. Please select an organization.")
        }
        
        // Set isWeighted to false as requested
        let isWeighted = false
        
        return try await homeRepository.fetchHealthScore(organizationId: organizationId, isWeighted: isWeighted)
    }
    
    func getHealthScoreTrend() async throws -> HealthScoreTrend {
        // Get organization ID from OrganizationUseCase (priority: selected > user default)
        guard let organizationId = organizationUseCase.getActiveOrganization() else {
            throw APIError.invalidResponse("Organization ID not found. Please select an organization.")
        }
        
        // Set default values as requested: Last7Days and Daily
        let dateType: DateType = .last7Days
        let resolutionType: DateResolutionType = .daily
        
        return try await homeRepository.fetchHealthScoreTrend(organizationId: organizationId, dateType: dateType, resolutionType: resolutionType)
    }
} 