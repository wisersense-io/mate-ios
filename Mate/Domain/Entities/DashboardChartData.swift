import Foundation
import SwiftUI

// MARK: - Dashboard Date Type
enum DashboardDateType: Int, CaseIterable {
    case thisWeek = 0
    case last7Days = 1
    case lastWeek = 2
    case last15Days = 3
    case last30Days = 4
    case last90Days = 5
    case thisMonth = 6
    case lastMonth = 7
    case last3Months = 8
    case last6Months = 9
    
    var localizationKey: String {
        switch self {
        case .thisWeek:
            return "key_this_week"
        case .last7Days:
            return "key_last_7_days"
        case .lastWeek:
            return "key_last_week"
        case .last15Days:
            return "key_last_15_days"
        case .last30Days:
            return "key_last_30_days"
        case .last90Days:
            return "key_last_90_days"
        case .thisMonth:
            return "key_this_month"
        case .lastMonth:
            return "key_last_month"
        case .last3Months:
            return "key_last_3_month"
        case .last6Months:
            return "key_last_6_month"
        }
    }
}

// MARK: - Dashboard Date Resolution Type
enum DashboardDateResolutionType: Int, CaseIterable {
    case daily = 0    // Günlük
    case weekly = 1   // Haftalık
    case monthly = 2  // Aylık
}

// MARK: - Dashboard Chart Data Entity
struct DashboardChartData: Identifiable {
    let id: String
    let type: DashboardChartType
    let titleKey: String
    var segments: [DashboardChartSegment]
    let centerValue: Int
    
    init(id: String, type: DashboardChartType, titleKey: String, segments: [DashboardChartSegment], centerValue: Int) {
        self.id = id
        self.type = type
        self.titleKey = titleKey
        self.segments = segments
        self.centerValue = centerValue
    }
}

// MARK: - Dashboard Chart Segment Entity
struct DashboardChartSegment: Identifiable {
    let id = UUID()
    let labelKey: String
    var value: Double // Percentage
    let color: ColorType
    let count: Int
    
    init(labelKey: String, value: Double, color: ColorType, count: Int) {
        self.labelKey = labelKey
        self.value = value
        self.color = color
        self.count = count
    }
}

// MARK: - Dashboard Chart Type
enum DashboardChartType: String, CaseIterable {
    case systemHealthScore = "system-health-score"
    case assetHealthScore = "asset-health-score"
    case systemAlarm = "system-alarm"
    
    var titleKey: String {
        switch self {
        case .systemHealthScore:
            return "key_health_score_of_systems_distributions"
        case .assetHealthScore:
            return "key_health_score_of_assets_distribution"
        case .systemAlarm:
            return "key_alarm_distributions_of_systems"
        }
    }
}

// MARK: - Color Type
enum ColorType: String, CaseIterable {
    case customRed = "customRed"
    case customOrange = "customOrange"
    case customYellow = "customYellow"
    case customBlue = "customBlue"
    case gray = "gray"
    
    var swiftUIColor: Color {
        switch self {
        case .customRed:
            return Color(red: 0.82, green: 0.04, blue: 0.04) // #d10b0b
        case .customOrange:
            return Color(red: 1.0, green: 0.34, blue: 0.13) // #ff5722
        case .customYellow:
            return Color(red: 1.0, green: 0.61, blue: 0.13) // #ff9c22
        case .customBlue:
            return Color(red: 0.13, green: 0.76, blue: 1.0) // #22c1ff
        case .gray:
            return Color.gray
        }
    }
}

// MARK: - Dashboard Chart Request Parameters
struct DashboardChartRequest {
    let organizationId: String
    let dateType: DashboardDateType
    
    init(organizationId: String, dateType: DashboardDateType) {
        self.organizationId = organizationId
        self.dateType = dateType
    }
}

// MARK: - Dashboard Date Filter
struct DashboardDateFilter {
    let dateType: DashboardDateType
    let localizationKey: String
    
    init(dateType: DashboardDateType) {
        self.dateType = dateType
        self.localizationKey = dateType.localizationKey
    }
    
    static let allFilters: [DashboardDateFilter] = DashboardDateType.allCases.map { DashboardDateFilter(dateType: $0) }
}

// MARK: - Conversion Extensions
extension DashboardChartData {
    func toDonutChartData() -> DonutChartData {
        let donutSegments = segments.map { segment in
            DonutChartSegment(
                label: segment.labelKey.localized(language: nil),
                value: segment.value,
                color: segment.color.swiftUIColor,
                count: segment.count
            )
        }
        
        return DonutChartData(
            id: id,
            title: titleKey.localized(language: nil),
            centerValue: centerValue,
            segments: donutSegments
        )
    }
}

// MARK: - System Alarm Trend Data Entity
struct SystemAlarmTrendData: Identifiable {
    let id = UUID()
    let titleKey: String
    let series: [SystemAlarmTrendSeries]
    let xAxisLabels: [String]
    
    init(titleKey: String, series: [SystemAlarmTrendSeries], xAxisLabels: [String]) {
        self.titleKey = titleKey
        self.series = series
        self.xAxisLabels = xAxisLabels
    }
}

// MARK: - System Alarm Trend Series
struct SystemAlarmTrendSeries: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let data: [Double]
    let color: ColorType
    
    init(name: String, data: [Double], color: ColorType) {
        self.name = name
        self.data = data
        self.color = color
    }
}

// MARK: - System Alarm Trend Item
struct SystemAlarmTrendItem {
    let dateString: String
    let s1: Double // Temperature alarms
    let s2: Double // MaxRMS alarms  
    let s3: Double // MaxVRMS alarms
    let s4: Double // MaxCF alarms
    
    init(dateString: String, s1: Double, s2: Double, s3: Double, s4: Double) {
        self.dateString = dateString
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3
        self.s4 = s4
    }
}

// MARK: - Note: Using existing localization system from LocalizationManager 
