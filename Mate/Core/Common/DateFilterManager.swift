import Foundation
import SwiftUI

// MARK: - Date Filter Manager (Ortak Kullanım)

class DateFilterManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DateFilterManager()
    
    private init() {}
    
    // MARK: - Available Filters (Tüm Ekranlar İçin)
    
    static let availableFilters: [DashboardDateFilter] = [
        DashboardDateFilter(dateType: .thisWeek),
        DashboardDateFilter(dateType: .last7Days),
        DashboardDateFilter(dateType: .lastWeek),
        DashboardDateFilter(dateType: .last15Days),
        DashboardDateFilter(dateType: .last30Days),
        DashboardDateFilter(dateType: .last90Days),
        DashboardDateFilter(dateType: .thisMonth),
        DashboardDateFilter(dateType: .lastMonth),
        DashboardDateFilter(dateType: .last3Months),
        DashboardDateFilter(dateType: .last6Months)
    ]
    
    // MARK: - Helper Methods
    
    /// Get localized title for date filter
    static func getLocalizedTitle(for dateType: DashboardDateType) -> String {
        return dateType.localizationKey.localized()
    }
    
    /// Get filter by date type
    static func getFilter(for dateType: DashboardDateType) -> DashboardDateFilter? {
        return availableFilters.first { $0.dateType == dateType }
    }
    
    /// Check if date type requires weekly resolution (React Native logic: dateType.rawValue > 3)
    static func shouldUseWeeklyResolution(for dateType: DashboardDateType) -> Bool {
        return dateType.rawValue > 3
    }
    
    /// Get appropriate resolution type for date filter
    static func getResolutionType(for dateType: DashboardDateType) -> DashboardDateResolutionType {
        if shouldUseWeeklyResolution(for: dateType) {
            return .weekly
        } else {
            return .daily
        }
    }
    
    /// Convert DashboardDateType to API dateType parameter
    static func getAPIDateType(for dateType: DashboardDateType) -> Int {
        // 1 aylık'tan fazla veriler için haftalık yap
        if shouldUseWeeklyResolution(for: dateType) {
            return DashboardDateResolutionType.weekly.rawValue
        }
        
        return dateType.rawValue
    }
    
    // MARK: - Default Filters for Different Screens
    
    /// Default filter for Dashboard screen
    static let defaultDashboardFilter: DashboardDateType = .last7Days
    
    /// Default filter for System Detail screen
    static let defaultSystemDetailFilter: DashboardDateType = .last7Days
    
    /// Default filter for Home screen
    static let defaultHomeFilter: DashboardDateType = .last7Days
    
    // MARK: - Filter Validation
    
    /// Validate if date type is available
    static func isValidDateType(_ dateType: DashboardDateType) -> Bool {
        return availableFilters.contains { $0.dateType == dateType }
    }
    
    /// Get safe date type (fallback to default if invalid)
    static func getSafeDateType(_ dateType: DashboardDateType?, defaultType: DashboardDateType) -> DashboardDateType {
        guard let dateType = dateType, isValidDateType(dateType) else {
            return defaultType
        }
        return dateType
    }
} 