import Foundation

// MARK: - Organization Domain Entity

struct Organization: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let parentId: String?
    var children: [Organization] = []
    var level: Int = 0
    var isExpanded: Bool = false
    
    // Helper computed properties
    var hasChildren: Bool {
        return !children.isEmpty
    }
    
    var isRootLevel: Bool {
        return parentId == nil
    }
    
    static func == (lhs: Organization, rhs: Organization) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Organization Tree Helper

struct OrganizationTree {
    static func buildTree(from organizations: [Organization]) -> [Organization] {
        var organizationMap: [String: Organization] = [:]
        
        // Create map of all organizations
        for org in organizations {
            organizationMap[org.id] = org
        }
        
        // Find root organizations and build tree
        var rootOrganizations: [Organization] = []
        
        for org in organizations {
            if org.parentId == nil {
                // Root organization
                let rootOrg = buildSubTree(for: org, from: organizationMap, level: 0)
                rootOrganizations.append(rootOrg)
            }
        }
        
        return rootOrganizations
    }
    
    private static func buildSubTree(for organization: Organization, from orgMap: [String: Organization], level: Int) -> Organization {
        var org = organization
        org.level = level
        
        // Find children
        let children = orgMap.values.filter { $0.parentId == organization.id }
        
        // Recursively build children
        org.children = children.map { child in
            buildSubTree(for: child, from: orgMap, level: level + 1)
        }
        
        return org
    }
    
    static func flattenTree(_ organizations: [Organization], includeCollapsed: Bool = false) -> [Organization] {
        var flatList: [Organization] = []
        
        func addToList(_ org: Organization) {
            flatList.append(org)
            
            if org.isExpanded || includeCollapsed {
                for child in org.children {
                    addToList(child)
                }
            }
        }
        
        for org in organizations {
            addToList(org)
        }
        
        return flatList
    }
    
    static func searchOrganizations(_ organizations: [Organization], query: String) -> [Organization] {
        guard !query.isEmpty else { return organizations }
        
        var results: [Organization] = []
        
        func searchInTree(_ org: Organization) {
            if org.name.localizedCaseInsensitiveContains(query) {
                results.append(org)
            }
            
            for child in org.children {
                searchInTree(child)
            }
        }
        
        for org in organizations {
            searchInTree(org)
        }
        
        return results
    }
} 