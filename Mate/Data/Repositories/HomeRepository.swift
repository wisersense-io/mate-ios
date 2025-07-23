import Foundation

// MARK: - Home Repository Implementation
class HomeRepository: HomeRepositoryProtocol {
    
    private let networkDataSource: HomeNetworkDataSourceProtocol
    
    init(networkDataSource: HomeNetworkDataSourceProtocol) {
        self.networkDataSource = networkDataSource
    }
    
    func fetchDashboardInfo(organizationId: String) async throws -> HomeDashboardInfo {
        let responseDTO = try await networkDataSource.fetchDashboardInfo(organizationId: organizationId)
        return try responseDTO.toDomain()
    }
    
    func fetchHealthScore(organizationId: String, isWeighted: Bool) async throws -> HealthScore {
        let responseDTO = try await networkDataSource.fetchHealthScore(organizationId: organizationId, isWeighted: isWeighted)
        
        // Check for API errors
        if responseDTO.hasError {
            print("❌ Health Score API Error: \(responseDTO.error ?? "Unknown error")")
            throw APIError.invalidResponse(responseDTO.error ?? "Health score fetch failed")
        }
        
        // Check if data exists
        guard let scoreData = responseDTO.data else {
            print("❌ Health Score data is nil")
            throw APIError.invalidResponse("No health score data received")
        }
        
        return HealthScore(score: scoreData, organizationId: organizationId)
    }
    
    func fetchHealthScoreTrend(organizationId: String, dateType: DateType = .last7Days, resolutionType: DateResolutionType = .daily) async throws -> HealthScoreTrend {
        let responseDTO = try await networkDataSource.fetchHealthScoreTrend(organizationId: organizationId, dateType: dateType, resolutionType: resolutionType)
        
        // Check for API errors
        if responseDTO.hasError {
            print("❌ Health Score Trend API Error: \(responseDTO.error ?? "Unknown error")")
            throw APIError.invalidResponse(responseDTO.error ?? "Health score trend fetch failed")
        }
        
        // Check if data exists
        guard let trendData = responseDTO.data else {
            print("❌ Health Score Trend data is nil")
            throw APIError.invalidResponse("No health score trend data received")
        }
        
        // Convert DTO to domain entities
        let trendItems = trendData.convertToHealthScoreTrendData()
        
        return HealthScoreTrend(
            items: trendItems,
            dateType: dateType,
            resolutionType: resolutionType,
            organizationId: organizationId
        )
    }
} 