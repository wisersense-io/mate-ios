import Foundation

// MARK: - Home Dashboard DTOs
struct HomeDashboardInfoResponseDTO: Decodable {
    let deviceCount: HomeDashboardValueResponseDTO
    let systemCount: HomeDashboardValueResponseDTO
    let assetCount: HomeDashboardValueResponseDTO
    let systemsWithAlarms: HomeDashboardValueResponseDTO
}

struct HomeDashboardValueResponseDTO: Decodable {
    let Value: HomeDashboardDataResponseDTO
}

struct HomeDashboardDataResponseDTO: Decodable {
    let data: HomeDashboardDataValueDTO?
    let error: String?
    let errorCode: Int
    let hasError: Bool
}

// Data can be either Int or complex object for systemsWithAlarms
enum HomeDashboardDataValueDTO: Decodable {
    case intValue(Int)
    case systemAlarmData(SystemAlarmDataDTO)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            self = .intValue(intValue)
        } else if let systemData = try? container.decode(SystemAlarmDataDTO.self) {
            self = .systemAlarmData(systemData)
        } else {
            throw DecodingError.typeMismatch(
                HomeDashboardDataValueDTO.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int or SystemAlarmDataDTO")
            )
        }
    }
}

struct SystemAlarmDataDTO: Decodable {
    let systemInAlarmStateCount: Int
    let totalSystemCount: Int
}

// MARK: - DTO to Domain Mappers
extension HomeDashboardInfoResponseDTO {
    func toDomain() throws -> HomeDashboardInfo {
        // Extract device count
        guard case .intValue(let deviceCount) = deviceCount.Value.data else {
            throw APIError.invalidResponse("Invalid device count data")
        }
        
        // Extract system count
        guard case .intValue(let systemCount) = systemCount.Value.data else {
            throw APIError.invalidResponse("Invalid system count data")
        }
        
        // Extract asset count
        guard case .intValue(let assetCount) = assetCount.Value.data else {
            throw APIError.invalidResponse("Invalid asset count data")
        }
      
        
        // Extract systems with alarms data
        guard case .systemAlarmData(let systemAlarmData) = systemsWithAlarms.Value.data else {
            throw APIError.invalidResponse("Invalid systems with alarms data")
        }
        
        return HomeDashboardInfo(
            deviceCount: deviceCount,
            systemCount: systemCount,
            assetCount: assetCount,
            systemsWithAlarms: systemAlarmData.systemInAlarmStateCount,
            totalSystemCount: systemAlarmData.totalSystemCount,
            systemInAlarmStateCount: systemAlarmData.systemInAlarmStateCount
        )
    }
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidResponse(String)
    case networkError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse(let message):
            return message
        case .networkError:
            return "network_error".localized()
        case .decodingError:
            return "invalid_response".localized()
        }
    }
}

// MARK: - Widget Response Base Types
struct WidgetResult<T: Decodable>: Decodable {
    let data: T?
    let error: String?
    let errorCode: Int
    let hasError: Bool
}

struct WidgetListResult<T: Decodable>: Decodable {
    let data: [T]?
    let error: String?
    let errorCode: Int
    let hasError: Bool
}

struct WidgetIntegerResult: Decodable {
    let data: Int?
    let error: String?
    let errorCode: Int
    let hasError: Bool
}

struct WidgetDoubleResult: Decodable {
    let data: Double?
    let error: String?
    let errorCode: Int
    let hasError: Bool
}

// MARK: - Health Score Response DTO
typealias HealthScoreResponseDTO = WidgetDoubleResult 

// MARK: - Health Score Trend Enums and DTOs

enum DateType: Int, CaseIterable {
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
}

enum DateResolutionType: Int, CaseIterable {
    case daily = 0
    case weekly = 1
    case monthly = 2
}

struct SummaryValueRecDTO: Decodable {
    let dt: String  // Date string in format YYYYMMDDHHMMSS
    let v: Double   // Value
}

// MARK: - Health Score Trend Response DTO
typealias HealthScoreTrendResponseDTO = WidgetListResult<SummaryValueRecDTO>

// MARK: - Helper Extensions for Date Conversion
extension SummaryValueRecDTO {
    func getFormattedDate() -> String? {
        return DateHelper.getDateFromDateStr(dateStr: dt)
    }
    
    func toHealthScoreTrendItem() -> HealthScoreTrendItem? {
        guard let formattedDate = getFormattedDate() else { return nil }
        
        return HealthScoreTrendItem(
            label: formattedDate,
            value: Double(String(format: "%.2f", v)) ?? 0.0
        )
    }
}

// MARK: - Date Helper
struct DateHelper {
    static func getDateFromDateStr(dateStr: String) -> String? {
        guard dateStr.count == 14 else {
            print("❌ Invalid date string length: \(dateStr)")
            return nil
        }
        
        let yearStr = String(dateStr.prefix(4))
        let monthStr = String(dateStr.dropFirst(4).prefix(2))
        let dayStr = String(dateStr.dropFirst(6).prefix(2))
        
        guard let year = Int(yearStr),
              let month = Int(monthStr),
              let day = Int(dayStr) else {
            print("❌ Could not parse date components from: \(dateStr)")
            return nil
        }
        
        // Create date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        guard let date = Calendar.current.date(from: dateComponents) else {
            print("❌ Could not create date from components: \(dateComponents)")
            return nil
        }
        
        // Format date to localized string
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale.current
        
        return formatter.string(from: date)
    }
}

// MARK: - Array Extension for Conversion
extension Array where Element == SummaryValueRecDTO {
    func convertToHealthScoreTrendData() -> [HealthScoreTrendItem] {
        var result: [HealthScoreTrendItem] = []
        
        for item in self {
            if let trendItem = item.toHealthScoreTrendItem() {
                result.append(trendItem)
            } else {
                print("⚠️ Could not convert SummaryValueRecDTO to HealthScoreTrendItem: \(item)")
            }
        }
        
        print("✅ Converted \(self.count) items to \(result.count) trend items")
        return result
    }
} 
