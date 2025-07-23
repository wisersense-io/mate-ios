import Foundation
import SwiftUI

@MainActor
class OrganizationSelectorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var organizations: [Organization] = []
    @Published var filteredOrganizations: [Organization] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedOrganization: Organization?
    @Published var showSearchResults = false
    @Published var expandedOrganizations: Set<String> = []
    
    // MARK: - Dependencies
    private let organizationUseCase: OrganizationUseCaseProtocol
    
    // MARK: - Computed Properties
    var displayOrganizations: [Organization] {
        if showSearchResults && !searchText.isEmpty {
            return filteredOrganizations
        } else {
            return OrganizationTree.flattenTree(organizations)
        }
    }
    
    var hasSelectedOrganization: Bool {
        return selectedOrganization != nil
    }
    
    // MARK: - Initialization
    init(organizationUseCase: OrganizationUseCaseProtocol) {
        self.organizationUseCase = organizationUseCase
        loadSelectedOrganization()
    }
    
    // MARK: - Public Methods
    func loadOrganizations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let tree = try await organizationUseCase.getOrganizationTree()
            self.organizations = tree
            print("✅ OrganizationSelectorViewModel: Loaded \(tree.count) root organizations")
            
            // Expand organizations to find and show selected organization
            await expandToSelectedOrganization()
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ OrganizationSelectorViewModel: Error loading organizations: \(error)")
        }
        
        isLoading = false
    }
    
    func searchOrganizations() async {
        guard !searchText.isEmpty, searchText.count >= 2 else {
            showSearchResults = false
            filteredOrganizations = []
            return
        }
        
        do {
            let results = try await organizationUseCase.searchOrganizations(query: searchText)
            self.filteredOrganizations = results
            self.showSearchResults = true
            print("🔍 OrganizationSelectorViewModel: Found \(results.count) organizations for '\(searchText)'")
        } catch {
            print("❌ OrganizationSelectorViewModel: Search error: \(error)")
        }
    }
    
    func selectOrganization(_ organization: Organization) {
        selectedOrganization = organization
        organizationUseCase.selectOrganization(organization.id)
        print("✅ OrganizationSelectorViewModel: Selected organization: \(organization.name)")
    }
    
    func toggleExpansion(for organizationId: String) {
        if expandedOrganizations.contains(organizationId) {
            expandedOrganizations.remove(organizationId)
        } else {
            expandedOrganizations.insert(organizationId)
        }
        updateOrganizationTree()
    }
    
    func clearSearch() {
        searchText = ""
        showSearchResults = false
        filteredOrganizations = []
    }
    
    // MARK: - Private Methods
    
    private func loadSelectedOrganization() {
        if let organizationId = organizationUseCase.getActiveOrganization() {
            Task {
                do {
                    if let organization = try await organizationUseCase.findOrganization(by: organizationId) {
                        self.selectedOrganization = organization
                        print("✅ OrganizationSelectorViewModel: Loaded selected organization: \(organization.name)")
                    }
                } catch {
                    print("❌ OrganizationSelectorViewModel: Error loading selected organization: \(error)")
                }
            }
        }
    }
    
    private func expandToSelectedOrganization() async {
        guard let selectedOrg = selectedOrganization else { return }
        
        do {
            let path = try await organizationUseCase.getOrganizationPath(for: selectedOrg.id)
            
            // Expand all organizations in the path
            for org in path {
                if let parentId = org.parentId {
                    expandedOrganizations.insert(parentId)
                }
            }
            
            updateOrganizationTree()
            
        } catch {
            print("❌ OrganizationSelectorViewModel: Error expanding to selected organization: \(error)")
        }
    }
    
    private func updateOrganizationTree() {
        organizations = updateExpansionState(organizations)
    }
    
    private func updateExpansionState(_ orgs: [Organization]) -> [Organization] {
        return orgs.map { org in
            var updatedOrg = org
            updatedOrg.isExpanded = expandedOrganizations.contains(org.id)
            updatedOrg.children = updateExpansionState(updatedOrg.children)
            return updatedOrg
        }
    }
}

// MARK: - Search Debouncing Extension

extension OrganizationSelectorViewModel {
    func performDebouncedSearch() {
        Task {
            // Wait a bit to debounce the search
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            // Check if search text is still the same
            await searchOrganizations()
        }
    }
} 