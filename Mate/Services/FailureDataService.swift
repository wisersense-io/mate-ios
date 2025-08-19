import Foundation
import SwiftUI

// Import necessary models
// Note: FailureTypes is defined in FailureTypes.swift
// Note: FailureItem and FailureData are defined in FailureModels.swift

// MARK: - FailureDataService
/// Service to manage failure data from FailureLists.json
/// Mimics React Native's getFailureByType functionality
class FailureDataService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = FailureDataService()
    
    // MARK: - Properties
    @Published private(set) var isLoaded = false
    @Published private(set) var isLoading = false
    @Published private(set) var loadError: String?
    
    private var failureData: FailureData?
    private var failureCache: [Int: FailureItem] = [:]
    
    // MARK: - Initialization
    private init() {
        Task {
            await loadFailureData()
        }
    }
    
    // MARK: - Public Methods
    
    /// Get failure item by type (mimics React Native's getFailureByType)
    /// - Parameter failureType: The failure type number
    /// - Returns: FailureItem if found, nil otherwise
    func getFailureByType(_ failureType: Int) -> FailureItem? {
        // Check cache first
        if let cachedItem = failureCache[failureType] {
            return cachedItem
        }
        
        // Get failure type key name
        let failureTypeEnum = FailureTypes.from(rawValue: failureType)
        let failureKey = failureTypeEnum.keyName
        
        // Search in failure data
        guard let failureData = self.failureData else {
            print("❌ FailureDataService: Failure data not loaded yet")
            return nil
        }
        
        // Find the failure item in the array
        for failureTypeDict in failureData.failureTypes {
            if let failureItem = failureTypeDict[failureKey] {
                // Cache the result for future use
                failureCache[failureType] = failureItem
                return failureItem
            }
        }
        
        print("⚠️ FailureDataService: Failure type \(failureType) (\(failureKey)) not found")
        return nil
    }
    
    /// Get localized caption for failure type
    /// - Parameters:
    ///   - failureType: The failure type number
    ///   - language: Language code (e.g., "en_US", "tr_TR")
    /// - Returns: Localized caption or unknown message
    func getLocalizedCaption(for failureType: Int, language: String = "en_US") -> String {
        if let failureItem = getFailureByType(failureType) {
            return failureItem.getCaption(language: language)
        }
        
        // Return fallback message
        if language.starts(with: "tr") {
            return "Bilinmeyen Teşhis Türü \(failureType)"
        } else {
            return "Unknown Diagnosis Type \(failureType)"
        }
    }
    
    /// Get SVG icon for failure type
    /// - Parameter failureType: The failure type number
    /// - Returns: SVG icon string if found, nil otherwise
    func getIconSVG(for failureType: Int) -> String? {
        if let failureItem = getFailureByType(failureType) {
            return failureItem.icon
        }
        return nil
    }
    
    /// Check if failure type has visible icon
    /// - Parameter failureType: The failure type number
    /// - Returns: True if failure type has a visible icon
    func hasVisibleIcon(for failureType: Int) -> Bool {
        if let failureItem = getFailureByType(failureType) {
            return failureItem.visible && !failureItem.icon.isEmpty
        }
        return false
    }
    
    /// Check if failure data is loaded
    var isDataReady: Bool {
        return isLoaded && failureData != nil
    }
    
    /// Force reload failure data
    func reloadData() async {
        failureCache.removeAll()
        await loadFailureData()
    }
    
    // MARK: - Private Methods
    
    /// Load failure data from JSON file
    @MainActor
    private func loadFailureData() async {
        guard !isLoading else { return }
        
        isLoading = true
        loadError = nil
        
        do {
            print("📂 FailureDataService: Loading failure data from FailureLists.json...")
            
            // Get bundle path for JSON file
            guard let path = Bundle.main.path(forResource: "FailureLists", ofType: "json") else {
                throw FailureDataError.fileNotFound
            }
            
            // Read JSON data
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
            
            // Decode JSON
            let decoder = JSONDecoder()
            let failureData = try decoder.decode(FailureData.self, from: jsonData)
            
            // Store data
            self.failureData = failureData
            
            // Clear cache to ensure fresh data
            failureCache.removeAll()
            
            isLoaded = true
            isLoading = false
            
            print("✅ FailureDataService: Successfully loaded \(failureData.failureTypes.count) failure type groups")
            
        } catch {
            print("❌ FailureDataService: Failed to load failure data - \(error.localizedDescription)")
            
            loadError = error.localizedDescription
            isLoaded = false
            isLoading = false
            
            // Additional error details
            if let decodingError = error as? DecodingError {
                print("🔍 FailureDataService: Decoding error details: \(decodingError)")
            }
        }
    }
}

// MARK: - Error Types
enum FailureDataError: LocalizedError {
    case fileNotFound
    case decodingFailed(String)
    case dataCorrupted
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "FailureLists.json file not found in bundle"
        case .decodingFailed(let details):
            return "Failed to decode JSON data: \(details)"
        case .dataCorrupted:
            return "Failure data is corrupted or invalid"
        }
    }
}

// MARK: - Extension for LocalizationManager Integration
extension FailureDataService {
    
    /// Get localized caption using LocalizationManager
    /// - Parameters:
    ///   - failureType: The failure type number
    ///   - localizationManager: The localization manager instance
    /// - Returns: Localized caption
    func getLocalizedCaption(for failureType: Int, localizationManager: LocalizationManager) -> String {
        let language = localizationManager.currentLanguage == .turkish ? "tr_TR" : "en_US"
        return getLocalizedCaption(for: failureType, language: language)
    }
    
    /// Get SVG icon using LocalizationManager (convenience method)
    /// - Parameters:
    ///   - failureType: The failure type number
    ///   - localizationManager: The localization manager instance
    /// - Returns: SVG icon string if found
    func getIconSVG(for failureType: Int, localizationManager: LocalizationManager) -> String? {
        return getIconSVG(for: failureType)
    }
}
