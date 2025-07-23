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
} 