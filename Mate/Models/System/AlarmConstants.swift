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

// MARK: - Timeline Record Type Enum

enum TimelineRecordType: Int, CaseIterable, Codable {
    case alarm = 0
    case diagnosis = 1
}

// MARK: - Filter Domain Models

struct AlarmFilter {
    let alarmType: AlarmType
    let alarmState: AlarmFilterType
    
    func toDTO() -> AlarmFilterDTO {
        return AlarmFilterDTO(alarmType: alarmType, alarmState: alarmState)
    }
}

struct DiagnosisFilter {
    let diagnosisType: Int
    let diagnosisActive: Int
    
    func toDTO() -> DiagnosisFilterDTO {
        return DiagnosisFilterDTO(domain: self)
    }
}

// MARK: - Timeline History Item Domain Model

struct TimelineHistoryItem: Identifiable, Equatable {
    let id: String
    let recordType: TimelineRecordType
    let recordId: String
    let systemId: String
    let assetId: String
    let pointId: String?
    let alarmType: AlarmType
    let alarmStage: Int
    let startedAt: String
    let finishedAt: String?
    let alarmackBy: String?
    let alarmackAt: String?
    let alarmSetValue: Double?
    let alarmResetValue: Double?
    let alarmAckComment: String?
    let alarmStartThresholdValue: Double?
    let alarmEndThresholdValue: Double?
    let diagnosisRawDataId: String?
    let diagnosisStartedBy: String?
    let diagnosisOwner: Int
    let diagnosisState: Int
    let diagnosisType: Int
    let diagnosisStage: Int
    let diagnosislevel: Int
    let diagnosisStartingComment: String?
    let diagnosisFinishedBy: String?
    let diagnosisFinishingComment: String?
    let diagnosisActive: Int
    let datetime: String
    let diagnosisApprovedBy: String?
    let diagnosisDissapprovedBy: String?
    let diagnosisApprovedAt: String?
    let diagnosisDissapprovedAt: String?
    let diagnosisRawDataDateTime: String?
    
    init(
        recordType: TimelineRecordType,
        recordId: String,
        systemId: String,
        assetId: String,
        pointId: String?,
        alarmType: AlarmType,
        alarmStage: Int,
        startedAt: String,
        finishedAt: String?,
        alarmackBy: String?,
        alarmackAt: String?,
        alarmSetValue: Double?,
        alarmResetValue: Double?,
        alarmAckComment: String?,
        alarmStartThresholdValue: Double?,
        alarmEndThresholdValue: Double?,
        diagnosisRawDataId: String?,
        diagnosisStartedBy: String?,
        diagnosisOwner: Int,
        diagnosisState: Int,
        diagnosisType: Int,
        diagnosisStage: Int,
        diagnosislevel: Int,
        diagnosisStartingComment: String?,
        diagnosisFinishedBy: String?,
        diagnosisFinishingComment: String?,
        diagnosisActive: Int,
        datetime: String,
        diagnosisApprovedBy: String?,
        diagnosisDissapprovedBy: String?,
        diagnosisApprovedAt: String?,
        diagnosisDissapprovedAt: String?,
        diagnosisRawDataDateTime: String?
    ) {
        self.id = recordId
        self.recordType = recordType
        self.recordId = recordId
        self.systemId = systemId
        self.assetId = assetId
        self.pointId = pointId
        self.alarmType = alarmType
        self.alarmStage = alarmStage
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.alarmackBy = alarmackBy
        self.alarmackAt = alarmackAt
        self.alarmSetValue = alarmSetValue
        self.alarmResetValue = alarmResetValue
        self.alarmAckComment = alarmAckComment
        self.alarmStartThresholdValue = alarmStartThresholdValue
        self.alarmEndThresholdValue = alarmEndThresholdValue
        self.diagnosisRawDataId = diagnosisRawDataId
        self.diagnosisStartedBy = diagnosisStartedBy
        self.diagnosisOwner = diagnosisOwner
        self.diagnosisState = diagnosisState
        self.diagnosisType = diagnosisType
        self.diagnosisStage = diagnosisStage
        self.diagnosislevel = diagnosislevel
        self.diagnosisStartingComment = diagnosisStartingComment
        self.diagnosisFinishedBy = diagnosisFinishedBy
        self.diagnosisFinishingComment = diagnosisFinishingComment
        self.diagnosisActive = diagnosisActive
        self.datetime = datetime
        self.diagnosisApprovedBy = diagnosisApprovedBy
        self.diagnosisDissapprovedBy = diagnosisDissapprovedBy
        self.diagnosisApprovedAt = diagnosisApprovedAt
        self.diagnosisDissapprovedAt = diagnosisDissapprovedAt
        self.diagnosisRawDataDateTime = diagnosisRawDataDateTime
    }
    
    static func == (lhs: TimelineHistoryItem, rhs: TimelineHistoryItem) -> Bool {
        return lhs.recordId == rhs.recordId
    }
}

// MARK: - Helper Extensions

extension TimelineHistoryItem {
    // Get display title based on record type
    var displayTitle: String {
        switch recordType {
        case .alarm:
            return getAlarmTitle()
        case .diagnosis:
            return getDiagnosisTitle()
        }
    }
    
    // Get expert name based on record type
    var expertName: String {
        switch recordType {
        case .alarm:
            return alarmackBy ?? "Unknown"
        case .diagnosis:
            return diagnosisStartedBy ?? "Unknown"
        }
    }
    
    // Get formatted start date
    var formattedStartDate: String {
        // Convert datetime string to readable format
        return datetime // For now, return as is - can be formatted later
    }
    
    // Get asset name (placeholder - can be enhanced)
    var assetName: String {
        return "Asset" // Placeholder - real implementation would fetch asset name
    }
    
    // Get point name (placeholder - can be enhanced)
    var pointName: String {
        return pointId ?? "Unknown Point"
    }
    
    private func getAlarmTitle() -> String {
        // Map alarm type to readable title
        switch alarmType {
        case .temperature:
            return "Sıcaklık Alarmı"
        case .vibrationRMS:
            return "Titreşim RMS"
        case .vibrationVRMS:
            return "Titreşim VRMS"  
        case .vibrationCF:
            return "Titreşim CF"
        case .acousticRMS:
            return "Akustik RMS"
        case .acousticCF:
            return "Akustik CF"
        case .magneticRMS:
            return "Manyetik RMS"
        case .magneticCF:
            return "Manyetik CF"
        case .proximityP2P:
            return "Yakınlık P2P"
        default:
            return "Bilinmeyen Alarm"
        }
    }
    
    private func getDiagnosisTitle() -> String {
        // Map diagnosis type to readable title - can be enhanced based on diagnosisType
        switch diagnosisType {
        case 1:
            return "Dengesizlik"
        case 2:
            return "Hizalama Problemi"
        case 3:
            return "Gevşeklik"
        default:
            return "Teşhis"
        }
    }
}

struct AlarmConstants {
    static let alarmTypeDropdownData: [AlarmTypeDropdownItem] = AlarmType.allCases.map { AlarmTypeDropdownItem(alarmType: $0) }
    
    static let alarmFilterDropdownData: [AlarmFilterDropdownItem] = AlarmFilterType.allCases.map { AlarmFilterDropdownItem(filterType: $0) }
    
    // Pagination constants
    static let pageSize = 50
} 