import Foundation

// MARK: - Organization DTOs

struct OrganizationResponseDTO: Codable {
    let id: String
    let name: String
    let parentId: String?
}

extension OrganizationResponseDTO {
    func toDomainEntity() -> Organization {
        return Organization(
            id: id,
            name: name,
            parentId: parentId
        )
    }
} 