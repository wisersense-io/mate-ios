import Foundation

// MARK: - Organization Storage Service

class OrganizationStorageService {
    private let userDefaults = UserDefaults.standard
    private let selectedOrganizationKey = "selectedOrganizationId"
    private let currentUserOrganizationKey = "currentUserOrganizationId"
    
    // MARK: - Selected Organization (User Choice)
    
    func saveSelectedOrganization(_ organizationId: String) {
        userDefaults.set(organizationId, forKey: selectedOrganizationKey)
        print("✅ OrganizationStorageService: Saved selected organization: \(organizationId)")
    }
    
    func getSelectedOrganization() -> String? {
        let organizationId = userDefaults.string(forKey: selectedOrganizationKey)
        print("📖 OrganizationStorageService: Retrieved selected organization: \(organizationId ?? "nil")")
        return organizationId
    }
    
    func removeSelectedOrganization() {
        userDefaults.removeObject(forKey: selectedOrganizationKey)
        print("🗑️ OrganizationStorageService: Removed selected organization")
    }
    
    // MARK: - Current User Organization (Default)
    
    func saveCurrentUserOrganization(_ organizationId: String) {
        userDefaults.set(organizationId, forKey: currentUserOrganizationKey)
        print("✅ OrganizationStorageService: Saved current user organization: \(organizationId)")
    }
    
    func getCurrentUserOrganization() -> String? {
        let organizationId = userDefaults.string(forKey: currentUserOrganizationKey)
        print("📖 OrganizationStorageService: Retrieved current user organization: \(organizationId ?? "nil")")
        return organizationId
    }
    
    func removeCurrentUserOrganization() {
        userDefaults.removeObject(forKey: currentUserOrganizationKey)
        print("🗑️ OrganizationStorageService: Removed current user organization")
    }
    
    // MARK: - Helper Methods
    
    /// Returns the organization ID that should be used across the app
    /// Priority: Selected organization > Current user organization
    func getActiveOrganization() -> String? {
        if let selectedId = getSelectedOrganization() {
            return selectedId
        }
        return getCurrentUserOrganization()
    }
    
    func clearAllOrganizationData() {
        removeSelectedOrganization()
        removeCurrentUserOrganization()
        print("🗑️ OrganizationStorageService: Cleared all organization data")
    }
} 