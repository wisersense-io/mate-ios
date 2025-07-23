import Foundation

// MARK: - Timeline History Request DTOs

struct TimelineHistoryRequestDTO: Codable {
    let systemId: String
    let dateType: Int
    let recordType: Int
    let alarmFilter: AlarmFilterDTO?
    let diagnosisFilter: DiagnosisFilterDTO?
    let skip: Int
    let take: Int
}

struct AlarmFilterDTO: Codable {
    let alarmType: Int
    let alarmState: Int
}

struct DiagnosisFilterDTO: Codable {
    let diagnosisType: Int
    let diagnosisActive: Int
}

// MARK: - Timeline History Response DTOs

struct TimelineHistoryResponseDTO: Codable {
    let data: [TimelineViewDTO]
}

struct TimelineViewDTO: Codable {
    let recordType: Int
    let recordId: String
    let systemId: String
    let assetId: String
    let pointId: String?
    let alarmType: Int
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
}

// MARK: - DTO Extensions for Domain Conversion

extension TimelineHistoryRequestDTO {
    init(
        systemId: String,
        dateType: DashboardDateType,
        recordType: TimelineRecordType,
        alarmFilter: AlarmFilter? = nil,
        diagnosisFilter: DiagnosisFilter? = nil,
        skip: Int,
        take: Int
    ) {
        self.systemId = systemId
        self.dateType = dateType.rawValue
        self.recordType = recordType.rawValue
        self.alarmFilter = alarmFilter?.toDTO()
        self.diagnosisFilter = diagnosisFilter?.toDTO()
        self.skip = skip
        self.take = take
    }
}

extension AlarmFilterDTO {
    init(alarmType: AlarmType, alarmState: AlarmFilterType) {
        self.alarmType = alarmType.rawValue
        self.alarmState = alarmState.rawValue
    }
}

extension DiagnosisFilterDTO {
    init(domain: DiagnosisFilter) {
        self.diagnosisType = domain.diagnosisType
        self.diagnosisActive = domain.diagnosisActive
    }
}

extension TimelineViewDTO {
    func toDomain() -> TimelineHistoryItem {
        return TimelineHistoryItem(
            recordType: TimelineRecordType(rawValue: recordType) ?? .alarm,
            recordId: recordId,
            systemId: systemId,
            assetId: assetId,
            pointId: pointId,
            alarmType: AlarmType(rawValue: alarmType) ?? .allAlarms,
            alarmStage: alarmStage,
            startedAt: startedAt,
            finishedAt: finishedAt,
            alarmackBy: alarmackBy,
            alarmackAt: alarmackAt,
            alarmSetValue: alarmSetValue,
            alarmResetValue: alarmResetValue,
            alarmAckComment: alarmAckComment,
            alarmStartThresholdValue: alarmStartThresholdValue,
            alarmEndThresholdValue: alarmEndThresholdValue,
            diagnosisRawDataId: diagnosisRawDataId,
            diagnosisStartedBy: diagnosisStartedBy,
            diagnosisOwner: diagnosisOwner,
            diagnosisState: diagnosisState,
            diagnosisType: diagnosisType,
            diagnosisStage: diagnosisStage,
            diagnosislevel: diagnosislevel,
            diagnosisStartingComment: diagnosisStartingComment,
            diagnosisFinishedBy: diagnosisFinishedBy,
            diagnosisFinishingComment: diagnosisFinishingComment,
            diagnosisActive: diagnosisActive,
            datetime: datetime,
            diagnosisApprovedBy: diagnosisApprovedBy,
            diagnosisDissapprovedBy: diagnosisDissapprovedBy,
            diagnosisApprovedAt: diagnosisApprovedAt,
            diagnosisDissapprovedAt: diagnosisDissapprovedAt,
            diagnosisRawDataDateTime: diagnosisRawDataDateTime
        )
    }
} 
