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
    
    func getSystemLastDiagnosis(systemId: String, dateType: Int) async throws -> [LastDiagnosis] {
        let diagnosisResponse = try await networkDataSource.fetchSystemLastDiagnosis(
            systemId: systemId,
            dateType: dateType
        )
        
        guard !diagnosisResponse.hasError,
              let diagnosisData = diagnosisResponse.data else {
            if let errorMessage = diagnosisResponse.error {
                throw AuthError.serverError(errorMessage, errorCode: diagnosisResponse.errorCode)
            } else {
                throw AuthError.serverError("Failed to fetch diagnosis data", errorCode: 500)
            }
        }
        
        return diagnosisData.toDomain()
    }
} 
