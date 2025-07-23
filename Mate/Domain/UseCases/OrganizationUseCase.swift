import Foundation

// MARK: - Organization Use Case Protocol

protocol OrganizationUseCaseProtocol {
    func getOrganizations() async throws -> [Organization]
    func getOrganizationTree() async throws -> [Organization]
    func searchOrganizations(query: String) async throws -> [Organization]
    func selectOrganization(_ organizationId: String)
    func getSelectedOrganization() -> String?
    func getCurrentUserOrganization() -> String?
    func getActiveOrganization() -> String?
    func findOrganization(by id: String) async throws -> Organization?
    func getOrganizationPath(for organizationId: String) async throws -> [Organization]
}

// MARK: - Organization Use Case Implementation

class OrganizationUseCase: OrganizationUseCaseProtocol {
    private let organizationRepository: OrganizationRepositoryProtocol
    private let organizationStorage: OrganizationStorageService
    private var cachedOrganizations: [Organization] = []
    private var cachedTree: [Organization] = []
    
    init(
        organizationRepository: OrganizationRepositoryProtocol,
        organizationStorage: OrganizationStorageService
    ) {
        self.organizationRepository = organizationRepository
        self.organizationStorage = organizationStorage
    }
    
    func getOrganizations() async throws -> [Organization] {
        if cachedOrganizations.isEmpty {
            cachedOrganizations = try await organizationRepository.getOrganizations()
            print("✅ OrganizationUseCase: Loaded \(cachedOrganizations.count) organizations from repository")
        }
        return cachedOrganizations
    }
    
    func getOrganizationTree() async throws -> [Organization] {
        if cachedTree.isEmpty {
            let organizations = try await getOrganizations()
            cachedTree = OrganizationTree.buildTree(from: organizations)
            print("✅ OrganizationUseCase: Built tree with \(cachedTree.count) root organizations")
        }
        return cachedTree
    }
    
    func searchOrganizations(query: String) async throws -> [Organization] {
        let tree = try await getOrganizationTree()
        let results = OrganizationTree.searchOrganizations(tree, query: query)
        print("🔍 OrganizationUseCase: Found \(results.count) organizations for query: '\(query)'")
        return results
    }
    
    func selectOrganization(_ organizationId: String) {
        organizationStorage.saveSelectedOrganization(organizationId)
        print("✅ OrganizationUseCase: Selected organization: \(organizationId)")
    }
    
    func getSelectedOrganization() -> String? {
        return organizationStorage.getSelectedOrganization()
    }
    
    func getCurrentUserOrganization() -> String? {
        return organizationStorage.getCurrentUserOrganization()
    }
    
    func getActiveOrganization() -> String? {
        return organizationStorage.getActiveOrganization()
    }
    
    // MARK: - Helper Methods
    
    func findOrganization(by id: String) async throws -> Organization? {
        let organizations = try await getOrganizations()
        return organizations.first { $0.id == id }
    }
    
    func getOrganizationPath(for organizationId: String) async throws -> [Organization] {
        let organizations = try await getOrganizations()
        var path: [Organization] = []
        
        guard let targetOrg = organizations.first(where: { $0.id == organizationId }) else {
            return path
        }
        
        var currentOrg: Organization? = targetOrg
        
        while let org = currentOrg {
            path.insert(org, at: 0)
            
            if let parentId = org.parentId {
                currentOrg = organizations.first { $0.id == parentId }
            } else {
                currentOrg = nil
            }
        }
        
        return path
    }
    
    func refreshCache() {
        cachedOrganizations = []
        cachedTree = []
        print("🔄 OrganizationUseCase: Cache refreshed")
    }
} 