import Foundation
import Combine
import SwiftUI

@MainActor
class SystemHistoryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Filter states
    @Published var selectedAlarmType: AlarmType = .allAlarms
    @Published var selectedFilterType: AlarmFilterType = .allAlarms
    @Published var selectedDateFilter: DashboardDateType = DateFilterManager.defaultSystemDetailFilter
    
    // Timeline history data (real implementation)
    @Published var timelineHistoryData: [TimelineHistoryItem] = []
    @Published var isAlarmsLoading = false
    @Published var alarmsError: String?
    @Published var isDiagnosisLoading = false
    @Published var diagnosisError: String?
    
    // Pagination properties
    @Published var hasMorePages = true
    private var currentPage = 0
    private let pageSize = AlarmConstants.pageSize
    
    // MARK: - Properties
    
    let system: System
    let availableFilters: [DashboardDateFilter] = DateFilterManager.availableFilters
    
    // Dependencies
    private let systemHistoryUseCase: SystemHistoryUseCaseProtocol
    private var currentOrganizationId: String?
    
    // MARK: - Computed Properties
    
    // Filter data based on selected tab
    var alarmData: [TimelineHistoryItem] {
        return timelineHistoryData.filter { $0.recordType == .alarm }
    }
    
    var diagnosisData: [TimelineHistoryItem] {
        return timelineHistoryData.filter { $0.recordType == .diagnosis }
    }
    
    // MARK: - Initialization
    
    init(
        system: System,
        systemHistoryUseCase: SystemHistoryUseCaseProtocol
    ) {
        self.system = system
        self.systemHistoryUseCase = systemHistoryUseCase
    }
    
    // MARK: - Public Methods
    
    func loadAlarmHistory() async {
        guard !isAlarmsLoading else { return }
        
        isAlarmsLoading = true
        alarmsError = nil
        currentPage = 0
        hasMorePages = true
        
        do {
            print("🚨 SystemHistoryViewModel: Loading alarm history")
            print("  - System: \(system.key) (\(system.id))")
            print("  - Alarm Type: \(selectedAlarmType)")
            print("  - Filter Type: \(selectedFilterType)")
            print("  - Date Filter: \(selectedDateFilter)")
            print("  - Page: \(currentPage), Size: \(pageSize)")
            
            // Load first page
            let historyItems = try await systemHistoryUseCase.getAlarmHistory(
                systemId: system.id,
                dateType: selectedDateFilter,
                alarmType: selectedAlarmType,
                alarmFilterType: selectedFilterType,
                skip: currentPage * pageSize,
                take: pageSize
            )
            
            // Replace all data (fresh load)
            timelineHistoryData = historyItems
            hasMorePages = historyItems.count >= pageSize
            
            print("✅ SystemHistoryViewModel: Loaded \(alarmData.count) alarm items (hasMore: \(hasMorePages))")
            
        } catch {
            alarmsError = error.localizedDescription
            timelineHistoryData = []
            print("❌ SystemHistoryViewModel: Failed to load alarm history - \(error.localizedDescription)")
        }
        
        isAlarmsLoading = false
    }
    
    func loadDiagnosisHistory() async {
        guard !isDiagnosisLoading else { return }
        
        isDiagnosisLoading = true
        diagnosisError = nil
        currentPage = 0
        hasMorePages = true
        
        do {
            print("🔍 SystemHistoryViewModel: Loading diagnosis history")
            print("  - System: \(system.key) (\(system.id))")
            print("  - Date Filter: \(selectedDateFilter)")
            print("  - Page: \(currentPage), Size: \(pageSize)")
            
            // Load first page
            let historyItems = try await systemHistoryUseCase.getDiagnosisHistory(
                systemId: system.id,
                dateType: selectedDateFilter,
                skip: currentPage * pageSize,
                take: pageSize
            )
            
            // Replace all data (fresh load)
            timelineHistoryData = historyItems
            hasMorePages = historyItems.count >= pageSize
            
            print("✅ SystemHistoryViewModel: Loaded \(diagnosisData.count) diagnosis items (hasMore: \(hasMorePages))")
            
        } catch {
            diagnosisError = error.localizedDescription
            timelineHistoryData = []
            print("❌ SystemHistoryViewModel: Failed to load diagnosis history - \(error.localizedDescription)")
        }
        
        isDiagnosisLoading = false
    }
    
    func refreshAlarmHistory() async {
        await loadAlarmHistory()
    }
    
    func refreshDiagnosisHistory() async {
        await loadDiagnosisHistory()
    }
    
    func updateAlarmType(_ alarmType: AlarmType) async {
        guard selectedAlarmType != alarmType else { return }
        
        selectedAlarmType = alarmType
        await loadAlarmHistory()
    }
    
    func updateFilterType(_ filterType: AlarmFilterType) async {
        guard selectedFilterType != filterType else { return }
        
        selectedFilterType = filterType
        await loadAlarmHistory()
    }
    
    func updateDateFilter(_ dateType: DashboardDateType) async {
        guard selectedDateFilter != dateType else { return }
        
        selectedDateFilter = dateType
        
        print("Date filter changed to: \(dateType)")
        
        // Refresh both alarm and diagnosis data when date filter changes sequentially
        await loadAlarmHistory()
        await loadDiagnosisHistory()
    }
    
    // MARK: - Helper Methods
    
    func getLocalizedFilterTitle(_ dateType: DashboardDateType) -> String {
        return DateFilterManager.getLocalizedTitle(for: dateType)
    }
    
} 
