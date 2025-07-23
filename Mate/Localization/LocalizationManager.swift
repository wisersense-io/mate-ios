import Foundation
import SwiftUI

// MARK: - Supported Languages
enum Language: String, CaseIterable {
    case turkish = "tr"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .turkish:
            return "Türkçe"
        case .english:
            return "English"
        }
    }
    
    var flag: String {
        switch self {
        case .turkish:
            return "🇹🇷"
        case .english:
            return "🇺🇸"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        // Önce kaydedilmiş dil tercihi var mı kontrol et
        if let savedLanguage = userDefaults.string(forKey: "app_language"),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        } else {
            // Sistem dilini kontrol et
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = Language(rawValue: systemLanguage) ?? .english
        }
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
    }
    
    func localizedString(for key: String) -> String {
        if let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(key, bundle: bundle, comment: "")
        }
        return key
    }
}

// MARK: - String Extension for Easy Localization
extension String {
    func localized(language: Language? = nil) -> String {
        let targetLanguage = language ?? (UserDefaults.standard.string(forKey: "app_language").flatMap(Language.init) ?? .english)
        
        if let path = Bundle.main.path(forResource: targetLanguage.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        return self
    }
}

// MARK: - Environment Key for Localization
struct LocalizationEnvironmentKey: EnvironmentKey {
    static let defaultValue = LocalizationManager()
}

extension EnvironmentValues {
    var localization: LocalizationManager {
        get { self[LocalizationEnvironmentKey.self] }
        set { self[LocalizationEnvironmentKey.self] = newValue }
    }
} 