import Foundation

// Import necessary models
// Note: LastDiagnosis is defined in DiagnosisDTOs.swift

// MARK: - FailureItem Model (React Native'den çevrilen)
struct FailureItem: Codable {
    let group: String
    let visible: Bool
    let popular: Bool
    let icon: String
    let caption: [String: String]
    let diagnosis: [String: String]
    let recommendation: [String: String]
    let cause: [String: String]
    let resultIn: [String: String]
    let couplingTypes: [String]?
    let workingTypes: [String]
    let machineTypes: [String]
    
    // MARK: - Localized Properties
    
    /// Get localized caption based on language
    func getCaption(language: String = "en_US") -> String {
        return caption[language] ?? caption["en_US"] ?? "Unknown Diagnosis"
    }
    
    /// Get localized diagnosis based on language
    func getDiagnosis(language: String = "en_US") -> String {
        return diagnosis[language] ?? diagnosis["en_US"] ?? ""
    }
    
    /// Get localized recommendation based on language
    func getRecommendation(language: String = "en_US") -> String {
        return recommendation[language] ?? recommendation["en_US"] ?? ""
    }
    
    /// Get localized cause based on language
    func getCause(language: String = "en_US") -> String {
        return cause[language] ?? cause["en_US"] ?? ""
    }
    
    /// Get localized resultIn based on language
    func getResultIn(language: String = "en_US") -> String {
        return resultIn[language] ?? resultIn["en_US"] ?? ""
    }
}

// MARK: - FailureData Container
struct FailureData: Codable {
    let failureTypes: [[String: FailureItem]]
    
    private enum CodingKeys: String, CodingKey {
        case failureTypes
    }
}

// MARK: - Diagnosis Level Colors and Icons
enum DiagnosisLevel: Int, CaseIterable {
    case level0 = 0
    case level1 = 1
    case level2 = 2
    
    /// Get color for diagnosis level (matching React Native logic)
    var color: String {
        switch self {
        case .level0: return "red"
        case .level1: return "red"
        case .level2: return "red"
        }
    }
    
    /// Get SF Symbol for diagnosis level
    var sfSymbol: String {
        switch self {
        case .level0: return "checkmark.circle.fill"
        case .level1: return "exclamationmark.triangle.fill"
        case .level2: return "xmark.circle.fill"
        }
    }
    
    /// Get display name for level
    var displayName: String {
        switch self {
        case .level0: return "Normal"
        case .level1: return "Warning" 
        case .level2: return "Critical"
        }
    }
}

// MARK: - Enhanced LastDiagnosis with FailureItem Integration
extension LastDiagnosis {
    /// Get associated FailureItem from FailureDataService
    func getFailureItem() -> FailureItem? {
        return FailureDataService.shared.getFailureByType(self.type)
    }
    
    /// Get localized caption
    func getLocalizedCaption(language: String = "en_US") -> String {
        if let failureItem = getFailureItem() {
            return failureItem.getCaption(language: language)
        }
        return "Unknown Diagnosis Type \(self.type)"
    }
    
    /// Get diagnosis level enum
    var diagnosisLevel: DiagnosisLevel {
        return DiagnosisLevel(rawValue: self.level) ?? .level0
    }
}
