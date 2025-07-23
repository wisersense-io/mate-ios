import Foundation

// MARK: - Organization Repository Implementation

class OrganizationRepository: OrganizationRepositoryProtocol {
    private let networkDataSource: OrganizationNetworkDataSource
    
    init(networkDataSource: OrganizationNetworkDataSource) {
        self.networkDataSource = networkDataSource
    }
    
    func getOrganizations() async throws -> [Organization] {
        let organizationDTOs = try await networkDataSource.getOrganizations()
        
        let organizations = organizationDTOs.map { $0.toDomainEntity() }
        
        print("✅ OrganizationRepository: Successfully converted \(organizations.count) organizations to domain entities")
        
        return organizations
    }
} 