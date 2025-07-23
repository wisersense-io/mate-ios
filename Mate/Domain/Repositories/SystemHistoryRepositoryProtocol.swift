import Foundation

// MARK: - System History Repository Protocol

protocol SystemHistoryRepositoryProtocol {
    func fetchTimelineHistory(
        systemId: String,
        dateType: DashboardDateType,
        recordType: TimelineRecordType,
        alarmFilter: AlarmFilter?,
        diagnosisFilter: DiagnosisFilter?,
        skip: Int,
        take: Int
    ) async throws -> [TimelineHistoryItem]
} 