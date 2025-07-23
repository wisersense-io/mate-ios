import Foundation

// MARK: - Alarm Type Enum

enum AlarmType: Int, CaseIterable, Codable {
    case allAlarms = -1
    case temperature = 0
    case vibrationRMS = 1
    case vibrationVRMS = 2
    case vibrationCF = 3
    case acousticRMS = 20
    case acousticCF = 21
    case magneticRMS = 40
    case magneticCF = 41
    case proximityP2P = 60
    
    var localizationKey: String {
        switch self {
        case .allAlarms:
            return "key_all_alarms"
        case .temperature:
            return "key_temperature_alarm"
        case .vibrationRMS:
            return "key_vibrationRms"
        case .vibrationVRMS:
            return "key_vibrationVRms"
        case .vibrationCF:
            return "key_vibrationCf"
        case .acousticRMS:
            return "key_acousticRms"
        case .acousticCF:
            return "key_acousticCf"
        case .magneticRMS:
            return "key_magneticRms"
        case .magneticCF:
            return "key_magneticCf"
        case .proximityP2P:
            return "key_proximityp2p"
        }
    }
}

// MARK: - Alarm Filter Type Enum

enum AlarmFilterType: Int, CaseIterable, Codable {
    case allAlarms = 0
    case onlyActiveAlarms = 1
    case onlyPassiveAlarms = 2
    
    var localizationKey: String {
        switch self {
        case .allAlarms:
            return "key_all_alarms"
        case .onlyActiveAlarms:
            return "key_active_alarms"
        case .onlyPassiveAlarms:
            return "key_passive_alarms"
        }
    }
}

// MARK: - Alarm Filter Data Sources

struct AlarmTypeDropdownItem {
    let label: String
    let alarmType: AlarmType
    
    init(alarmType: AlarmType) {
        self.alarmType = alarmType
        self.label = alarmType.localizationKey
    }
}

struct AlarmFilterDropdownItem {
    let label: String
    let filterType: AlarmFilterType
    
    init(filterType: AlarmFilterType) {
        self.filterType = filterType
        self.label = filterType.localizationKey
    }
}

// MARK: - Data Sources

struct AlarmConstants {
    static let alarmTypeDropdownData: [AlarmTypeDropdownItem] = AlarmType.allCases.map { AlarmTypeDropdownItem(alarmType: $0) }
    
    static let alarmFilterDropdownData: [AlarmFilterDropdownItem] = AlarmFilterType.allCases.map { AlarmFilterDropdownItem(filterType: $0) }
} 