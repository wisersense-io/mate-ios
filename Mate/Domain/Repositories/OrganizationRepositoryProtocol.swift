import Foundation

// MARK: - Organization Repository Protocol

protocol OrganizationRepositoryProtocol {
    func getOrganizations() async throws -> [Organization]
} 