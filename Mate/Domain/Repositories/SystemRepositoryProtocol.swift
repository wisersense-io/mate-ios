import Foundation

protocol SystemRepositoryProtocol {
    func getSystems(organizationId: String, filter: Int, skip: Int, take: Int) async throws -> [System]
} 