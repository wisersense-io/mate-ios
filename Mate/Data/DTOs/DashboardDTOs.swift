import Foundation

// MARK: - Dashboard Chart Distribution DTOs

struct DashboardChartDistributionResponseDTO: Decodable {
    let systemHealthScoreDistribution: DashboardChartValueResponseDTO
    let assetHealthScoreDistribution: DashboardChartValueResponseDTO
    let systemAlarmDistribution: DashboardChartValueResponseDTO
}

struct DashboardChartValueResponseDTO: Decodable {
    let Value: DashboardChartDataResponseDTO
}

struct DashboardChartDataResponseDTO: Decodable {
    let data: [DashboardChartDataDTO]
    let errorCode: Int
    let hasError: Bool
    let error: String?
}

struct DashboardChartDataDTO: Decodable {
    // For health score distributions
    let region: String?
    let count: Int?
    
    // For alarm distribution
    let alarmType: Int?
    let countOfOk: Int?
    let countOfMonitor: Int?
    let countOfWarning: Int?
    let countOfDanger: Int?
    let countOfAlarm: Int?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode health score distribution fields
        region = try? container.decode(String.self, forKey: .region)
        count = try? container.decode(Int.self, forKey: .count)
        
        // Try to decode alarm distribution fields
        alarmType = try? container.decode(Int.self, forKey: .alarmType)
        countOfOk = try? container.decode(Int.self, forKey: .countOfOk)
        countOfMonitor = try? container.decode(Int.self, forKey: .countOfMonitor)
        countOfWarning = try? container.decode(Int.self, forKey: .countOfWarning)
        countOfDanger = try? container.decode(Int.self, forKey: .countOfDanger)
        countOfAlarm = try? container.decode(Int.self, forKey: .countOfAlarm)
    }
    
    private enum CodingKeys: String, CodingKey {
        case region, count
        case alarmType, countOfOk, countOfMonitor, countOfWarning, countOfDanger, countOfAlarm
    }
}

// MARK: - System Alarm Trend DTOs

struct SystemAlarmTrendResponseDTO: Decodable {
    let data: [SystemAlarmTrendItemDTO]
    let errorCode: Int
    let hasError: Bool
}

struct SystemAlarmTrendItemDTO: Decodable {
    let dt: String
    let s1: Double
    let s2: Double
    let s3: Double
    let s4: Double
}

// MARK: - Date Type Alias
// Use domain layer DashboardDateType

// MARK: - DTO to Domain Mappers
extension DashboardChartDistributionResponseDTO {
    func toDomainChartData() -> [DashboardChartData] {
        var chartDataArray: [DashboardChartData] = []
        
        // Map system health score distribution
        if let systemHealthData = systemHealthScoreDistribution.Value.data.toHealthScoreSegments() {
            let systemHealthChart = DashboardChartData(
                id: "system-health-distribution",
                type: .systemHealthScore,
                titleKey: "key_health_score_of_systems_distributions",
                segments: systemHealthData.segments,
                centerValue: systemHealthData.totalCount
            )
            chartDataArray.append(systemHealthChart)
        }
        
        // Map asset health score distribution
        if let assetHealthData = assetHealthScoreDistribution.Value.data.toHealthScoreSegments() {
            let assetHealthChart = DashboardChartData(
                id: "asset-health-distribution",
                type: .assetHealthScore,
                titleKey: "key_health_score_of_assets_distribution",
                segments: assetHealthData.segments,
                centerValue: assetHealthData.totalCount
            )
            chartDataArray.append(assetHealthChart)
        }
        
        // Map system alarm distribution
        if let alarmData = systemAlarmDistribution.Value.data.toAlarmSegments() {
            let alarmChart = DashboardChartData(
                id: "system-alarm-distribution",
                type: .systemAlarm,
                titleKey: "key_alarm_distributions_of_systems",
                segments: alarmData.segments,
                centerValue: alarmData.totalCount
            )
            chartDataArray.append(alarmChart)
        }
        
        return chartDataArray
    }
}

// MARK: - Helper Extensions
extension Array where Element == DashboardChartDataDTO {
    func toHealthScoreSegments() -> (segments: [DashboardChartSegment], totalCount: Int)? {
        var segments: [DashboardChartSegment] = []
        var totalCount = 0
        
        for item in self {
            guard let region = item.region,
                  let count = item.count else { continue }
            
            totalCount += count
            
            let segment = DashboardChartSegment(
                labelKey: region,
                value: Double(count),
                color: getHealthScoreColor(for: region),
                count: count
            )
            segments.append(segment)
        }
        
        guard !segments.isEmpty else { return nil }
        
        // Calculate percentages
        for i in 0..<segments.count {
            segments[i].value = (Double(segments[i].count) / Double(totalCount)) * 100.0
        }
        
        return (segments: segments, totalCount: totalCount)
    }
    
    func toAlarmSegments() -> (segments: [DashboardChartSegment], totalCount: Int)? {
        var segments: [DashboardChartSegment] = []
        var totalCount = 0
        
        for item in self {
            guard let alarmType = item.alarmType,
                  let countOfMonitor = item.countOfMonitor,
                  let countOfWarning = item.countOfWarning,
                  let countOfDanger = item.countOfDanger else { continue }
            
            let alarmTypeCount = countOfMonitor + countOfWarning + countOfDanger
            totalCount += alarmTypeCount
            
            let segment = DashboardChartSegment(
                labelKey: getAlarmTypeLabel(for: alarmType),
                value: Double(alarmTypeCount),
                color: getAlarmTypeColor(for: alarmType),
                count: alarmTypeCount
            )
            segments.append(segment)
        }
        
        guard !segments.isEmpty else { return nil }
        
        // Calculate percentages
        for i in 0..<segments.count {
            segments[i].value = (Double(segments[i].count) / Double(totalCount)) * 100.0
        }
        
        return (segments: segments, totalCount: totalCount)
    }
}

// MARK: - Color Helpers
private func getHealthScoreColor(for region: String) -> ColorType {
    switch region {
    case "keyNormal":
        return .customBlue
    case "keyMonitored":
        return .customYellow
    case "keyWarning":
        return .customOrange
    case "keyDanger":
        return .customRed
    default:
        return .gray
    }
}

private func getAlarmTypeColor(for alarmType: Int) -> ColorType {
    switch alarmType {
    case 0: // Temperature
        return .customRed
    case 1: // MaxRMS
        return .customOrange
    case 2: // MaxVRMS
        return .customYellow
    case 3: // MaxCF
        return .customBlue
    default:
        return .gray
    }
}

private func getAlarmTypeLabel(for alarmType: Int) -> String {
    switch alarmType {
    case 0: // Temperature
        return "key_temperature"
    case 1: // MaxRMS
        return "key_max_rms"
    case 2: // MaxVRMS
        return "key_max_vrms"
    case 3: // MaxCF
        return "key_max_cf"
    default:
        return "undefined"
    }
}

// MARK: - System Alarm Trend Mapping
extension SystemAlarmTrendResponseDTO {
    func toSystemAlarmTrendData() -> SystemAlarmTrendData {
        // Convert DTO items to domain items
        let trendItems = data.map { dto in
            SystemAlarmTrendItem(
                dateString: formatDateString(dto.dt),
                s1: dto.s1,
                s2: dto.s2,
                s3: dto.s3,
                s4: dto.s4
            )
        }
        
        // Extract data for each series
        let s1Data = trendItems.map { $0.s1 }
        let s2Data = trendItems.map { $0.s2 }
        let s3Data = trendItems.map { $0.s3 }
        let s4Data = trendItems.map { $0.s4 }
        
        // Create series with colors matching React Native
        let series = [
            SystemAlarmTrendSeries(name: "key_temperature", data: s1Data, color: .customRed),
            SystemAlarmTrendSeries(name: "key_max_rms", data: s2Data, color: .customOrange),
            SystemAlarmTrendSeries(name: "key_max_vrms", data: s3Data, color: .customYellow),
            SystemAlarmTrendSeries(name: "key_max_cf", data: s4Data, color: .customBlue)
        ]
        
        // Extract x-axis labels (formatted dates)
        let xAxisLabels = trendItems.map { $0.dateString }
        
        return SystemAlarmTrendData(
            titleKey: "key_health_score_trend_of_packets",
            series: series,
            xAxisLabels: xAxisLabels
        )
    }
    
    private func formatDateString(_ dateString: String) -> String {
        // Convert from "20250619000000" to localized date format
        guard dateString.count >= 8 else { return dateString }
        
        let yearStr = String(dateString.prefix(4))
        let monthStr = String(dateString.dropFirst(4).prefix(2))
        let dayStr = String(dateString.dropFirst(6).prefix(2))
        
        guard let year = Int(yearStr),
              let month = Int(monthStr),
              let day = Int(dayStr) else {
            return dateString
        }
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        guard let date = Calendar.current.date(from: dateComponents) else {
            return dateString
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale.current
        
        return formatter.string(from: date)
    }
} 