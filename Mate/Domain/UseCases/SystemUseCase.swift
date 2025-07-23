import Foundation

class SystemUseCase {
    private let systemRepository: SystemRepositoryProtocol
    
    init(systemRepository: SystemRepositoryProtocol) {
        self.systemRepository = systemRepository
    }
    
    func getSystems(organizationId: String, filter: SystemFilterType, skip: Int, take: Int) async throws -> [System] {
        let systems = try await systemRepository.getSystems(
            organizationId: organizationId,
            filter: filter.rawValue,
            skip: skip,
            take: take
        )
        
        return systems
    }
    
    func prepareDevices(from systems: [System]) -> [DeviceInfo] {
        return systems.prepareDevices()
    }
    
    func getSystemHealthScoreTrend(systemId: String, dateType: Int) async throws -> [SystemDetailTrendData] {
        return try await systemRepository.getSystemHealthScoreTrend(
            systemId: systemId,
            dateType: dateType
        )
    }
} 