import Foundation

// MARK: - Home Dashboard Domain Entities
struct HomeDashboardInfo {
    let deviceCount: Int
    let systemCount: Int
    let assetCount: Int
    let systemsWithAlarms: Int
    let totalSystemCount: Int
    let systemInAlarmStateCount: Int
}

struct HomeDashboardItem {
    let title: String
    let value: String
    
    enum ItemType {
        case deviceCount
        case systemCount
        case assetCount
        case devicesWithAlarms
        case alarmsRatio
    }
    
    let type: ItemType
    
    func localizedTitle(language: String) -> String {
        switch type {
        case .deviceCount:
            return NSLocalizedString("device_count", comment: "")
        case .systemCount:
            return NSLocalizedString("system_count", comment: "")
        case .assetCount:
            return NSLocalizedString("asset_count", comment: "")
        case .devicesWithAlarms:
            return NSLocalizedString("devices_with_alarms", comment: "")
        case .alarmsRatio:
            return NSLocalizedString("alarms_ratio", comment: "")
        }
    }
    
    var displayValue: String {
        switch type {
        case .alarmsRatio:
            return value
        default:
            return value
        }
    }
}

// MARK: - Health Score Domain Entity
struct HealthScore {
    let score: Double
    let organizationId: String
    
    init(score: Double, organizationId: String) {
        self.score = score
        self.organizationId = organizationId
    }
}

// MARK: - Health Score Trend Domain Entity
struct HealthScoreTrend {
    let items: [HealthScoreTrendItem]
    let dateType: DateType
    let resolutionType: DateResolutionType
    let organizationId: String
    
    init(items: [HealthScoreTrendItem], dateType: DateType, resolutionType: DateResolutionType, organizationId: String) {
        self.items = items
        self.dateType = dateType
        self.resolutionType = resolutionType
        self.organizationId = organizationId
    }
}

struct HealthScoreTrendItem: Equatable {
    let label: String
    let value: Double
    
    init(label: String, value: Double) {
        self.label = label
        self.value = value
    }
}

// MARK: - Helper Functions
extension HomeDashboardInfo {
    func toDashboardItems(language: String) -> [HomeDashboardItem] {
        let alarmRatio = calculateAlarmRatio(
            alarmCount: systemInAlarmStateCount,
            totalCount: totalSystemCount,
            language: language
        )
        
        return [
            HomeDashboardItem(
                title: "device_count",
                value: "\(deviceCount)",
                type: .deviceCount
            ),
            HomeDashboardItem(
                title: "system_count",
                value: "\(systemCount)",
                type: .systemCount
            ),
            HomeDashboardItem(
                title: "asset_count",
                value: "\(assetCount)",
                type: .assetCount
            ),
            HomeDashboardItem(
                title: "alarms_ratio",
                value: alarmRatio,
                type: .alarmsRatio
            )
        ]
    }
    
    private func calculateAlarmRatio(alarmCount: Int, totalCount: Int, language: String) -> String {
        guard totalCount > 0 else { return "%" }
        
        let ratio = (Double(alarmCount) / Double(totalCount)) * 100
        if ratio.isNaN { return "%" }
        
        let formattedRatio = String(format: "%.0f", ratio)
        return language == "tr" ? "%\(formattedRatio)" : "\(formattedRatio)%"
    }
}

import SwiftUI 
