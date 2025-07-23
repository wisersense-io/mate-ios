import Foundation

// MARK: - System History Use Case Protocol

protocol SystemHistoryUseCaseProtocol {
    func getAlarmHistory(
        systemId: String,
        dateType: DashboardDateType,
        alarmType: AlarmType,
        alarmFilterType: AlarmFilterType,
        skip: Int,
        take: Int
    ) async throws -> [TimelineHistoryItem]
    
    func getDiagnosisHistory(
        systemId: String,
        dateType: DashboardDateType,
        skip: Int,
        take: Int
    ) async throws -> [TimelineHistoryItem]
}

// MARK: - System History Use Case Implementation

class SystemHistoryUseCase: SystemHistoryUseCaseProtocol {
    
    private let repository: SystemHistoryRepositoryProtocol
    
    init(
        repository: SystemHistoryRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    func getAlarmHistory(
        systemId: String,
        dateType: DashboardDateType,
        alarmType: AlarmType,
        alarmFilterType: AlarmFilterType,
        skip: Int,
        take: Int
    ) async throws -> [TimelineHistoryItem] {
        print("🎯 SystemHistoryUseCase: Getting alarm history")
        print("  - systemId: \(systemId)")
        print("  - dateType: \(dateType)")
        print("  - alarmType: \(alarmType)")
        print("  - alarmFilterType: \(alarmFilterType)")
        print("  - pagination: skip=\(skip), take=\(take)")
        
        do {
            // Create alarm filter
            let alarmFilter = AlarmFilter(
                alarmType: alarmType,
                alarmState: alarmFilterType
            )
            
            // Fetch alarm history
            let historyItems = try await repository.fetchTimelineHistory(
                systemId: systemId,
                dateType: dateType,
                recordType: .alarm,
                alarmFilter: alarmFilter,
                diagnosisFilter: nil,
                skip: skip,
                take: take
            )
            
            // Filter only alarm items (additional safety)
            let alarmItems = historyItems.filter { $0.recordType == .alarm }
            
            print("✅ SystemHistoryUseCase: Successfully fetched \(alarmItems.count) alarm items")
            return alarmItems
            
        } catch {
            print("❌ SystemHistoryUseCase: Error getting alarm history: \(error)")
            throw error
        }
    }
    
    func getDiagnosisHistory(
        systemId: String,
        dateType: DashboardDateType,
        skip: Int,
        take: Int
    ) async throws -> [TimelineHistoryItem] {
        // Validate organization
        
        print("🎯 SystemHistoryUseCase: Getting diagnosis history")
        print("  - systemId: \(systemId)")
        print("  - dateType: \(dateType)")
        print("  - pagination: skip=\(skip), take=\(take)")
        
        do {
            // Create diagnosis filter (placeholder - can be enhanced)
            let diagnosisFilter = DiagnosisFilter(
                diagnosisType: 0, // All types
                diagnosisActive: 1 // Active only
            )
            
            // Fetch diagnosis history
            let historyItems = try await repository.fetchTimelineHistory(
                systemId: systemId,
                dateType: dateType,
                recordType: .diagnosis,
                alarmFilter: nil,
                diagnosisFilter: diagnosisFilter,
                skip: skip,
                take: take
            )
            
            // Filter only diagnosis items (additional safety)
            let diagnosisItems = historyItems.filter { $0.recordType == .diagnosis }
            
            print("✅ SystemHistoryUseCase: Successfully fetched \(diagnosisItems.count) diagnosis items")
            return diagnosisItems
            
        } catch {
            print("❌ SystemHistoryUseCase: Error getting diagnosis history: \(error)")
            throw error
        }
    }
} 
