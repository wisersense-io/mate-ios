import Foundation

class SystemRepository: SystemRepositoryProtocol {
    private let networkDataSource: SystemNetworkDataSourceProtocol
    
    init(networkDataSource: SystemNetworkDataSourceProtocol) {
        self.networkDataSource = networkDataSource
    }
    
    func getSystems(organizationId: String, filter: Int, skip: Int, take: Int) async throws -> [System] {
        let systemsResponse = try await networkDataSource.fetchSystems(
            organizationId: organizationId,
            filter: filter,
            skip: skip,
            take: take
        )
        
        return systemsResponse.data
    }
    
    func getSystemHealthScoreTrend(systemId: String, dateType: Int) async throws -> [SystemDetailTrendData] {
        let trendResponse = try await networkDataSource.fetchSystemHealthScoreTrend(
            systemId: systemId,
            dateType: dateType
        )
        
        return trendResponse.data
    }
} 