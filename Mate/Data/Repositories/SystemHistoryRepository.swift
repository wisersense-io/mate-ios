import Foundation

// MARK: - System History Repository Implementation

class SystemHistoryRepository: SystemHistoryRepositoryProtocol {
    
    private let networkDataSource: SystemHistoryNetworkDataSourceProtocol
    
    init(networkDataSource: SystemHistoryNetworkDataSourceProtocol) {
        self.networkDataSource = networkDataSource
    }
    
    func fetchTimelineHistory(
        systemId: String,
        dateType: DashboardDateType,
        recordType: TimelineRecordType,
        alarmFilter: AlarmFilter?,
        diagnosisFilter: DiagnosisFilter?,
        skip: Int,
        take: Int
    ) async throws -> [TimelineHistoryItem] {
        print("🏛️ SystemHistoryRepository: Fetching timeline history")
        print("  - systemId: \(systemId)")
        print("  - dateType: \(dateType)")
        print("  - recordType: \(recordType)")
        print("  - skip: \(skip), take: \(take)")
        
        do {
            // Create request DTO
            let requestDTO = TimelineHistoryRequestDTO(
                systemId: systemId,
                dateType: dateType,
                recordType: recordType,
                alarmFilter: alarmFilter,
                diagnosisFilter: diagnosisFilter,
                skip: skip,
                take: take
            )
            
            // Fetch from network
            let responseDTO = try await networkDataSource.fetchTimelineHistory(request: requestDTO)
            
            
            // Convert to domain models
            let historyItems = responseDTO.map { $0.toDomain() }
            
            print("✅ SystemHistoryRepository: Successfully converted \(historyItems.count) items")
            return historyItems
            
        } catch {
            print("❌ SystemHistoryRepository: Error fetching timeline history: \(error)")
            throw error
        }
    }
} 
