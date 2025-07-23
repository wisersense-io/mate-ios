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
    
    // Alarm data (placeholder for now)
    @Published var alarmData: [AlarmHistoryItem] = []
    @Published var isAlarmsLoading = false
    @Published var alarmsError: String?
    
    // Diagnosis data (placeholder for now)
    @Published var diagnosisData: [DiagnosisHistoryItem] = []
    @Published var isDiagnosisLoading = false
    @Published var diagnosisError: String?
    
    // MARK: - Properties
    
    let system: System
    let availableFilters: [DashboardDateFilter] = DateFilterManager.availableFilters
    
    // Dependencies (placeholder for future use)
    private let organizationUseCase: OrganizationUseCaseProtocol
    private var currentOrganizationId: String?
    
    // MARK: - Initialization
    
    init(system: System, organizationUseCase: OrganizationUseCaseProtocol) {
        self.system = system
        self.organizationUseCase = organizationUseCase
    }
    
    // MARK: - Public Methods
    
    func loadAlarmHistory() async {
        guard !isAlarmsLoading else { return }
        
        isAlarmsLoading = true
        alarmsError = nil
        
        do {
            // Get resolution type based on React Native logic
            let resolutionType = DateFilterManager.getResolutionType(for: selectedDateFilter)
            
            print("🚨 SystemHistoryViewModel: Loading alarm history")
            print("  - System: \(system.key)")
            print("  - Alarm Type: \(selectedAlarmType)")
            print("  - Filter Type: \(selectedFilterType)")
            print("  - Date Filter: \(selectedDateFilter)")
            print("  - Resolution: \(resolutionType)")
            
            // TODO: Implement actual API call
            // let alarmHistory = try await systemUseCase.getAlarmHistory(
            //     systemId: system.id,
            //     alarmType: selectedAlarmType,
            //     filterType: selectedFilterType,
            //     dateType: selectedDateFilter,
            //     resolutionType: resolutionType
            // )
            
            // Mock data for now
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            alarmData = createMockAlarmData()
            
            print("✅ SystemHistoryViewModel: Loaded \(alarmData.count) alarm history items")
            
        } catch {
            alarmsError = error.localizedDescription
            alarmData = []
            print("❌ SystemHistoryViewModel: Failed to load alarm history - \(error.localizedDescription)")
        }
        
        isAlarmsLoading = false
    }
    
    func loadDiagnosisHistory() async {
        guard !isDiagnosisLoading else { return }
        
        isDiagnosisLoading = true
        diagnosisError = nil
        
        do {
            print("🔍 SystemHistoryViewModel: Loading diagnosis history")
            print("  - System: \(system.key)")
            print("  - Date Filter: \(selectedDateFilter)")
            
            // TODO: Implement actual API call
            // let diagnosisHistory = try await systemUseCase.getDiagnosisHistory(
            //     systemId: system.id,
            //     dateType: selectedDateFilter
            // )
            
            // Mock data for now
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            diagnosisData = createMockDiagnosisData()
            
            print("✅ SystemHistoryViewModel: Loaded \(diagnosisData.count) diagnosis history items")
            
        } catch {
            diagnosisError = error.localizedDescription
            diagnosisData = []
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
        
        // Refresh both alarm and diagnosis data when date filter changes sequentially
        await loadAlarmHistory()
        await loadDiagnosisHistory()
    }
    
    // MARK: - Organization Management
    
    private func getOrganizationId() -> String? {
        return organizationUseCase.getSelectedOrganization()
    }
    
    func checkAndRefreshIfOrganizationChanged() async -> Bool {
        if let newOrganizationId = getOrganizationId(),
           newOrganizationId != currentOrganizationId {
            currentOrganizationId = newOrganizationId
            
            // Refresh all data when organization changes sequentially
            await loadAlarmHistory()
            await loadDiagnosisHistory()
            return true // Data was refreshed
        }
        return false // No refresh needed
    }
    
    // MARK: - Helper Methods
    
    func getLocalizedFilterTitle(_ dateType: DashboardDateType) -> String {
        return DateFilterManager.getLocalizedTitle(for: dateType)
    }
    
    // MARK: - Mock Data (Remove when API is ready)
    
    private func createMockAlarmData() -> [AlarmHistoryItem] {
        let mockItems = [
            AlarmHistoryItem(
                id: "1",
                title: "Dönel Gevşeklik",
                expert: "Umut Çetin",
                startDate: "19.06.2025 20:57:12",
                asset: "Motor",
                point: "Drive end",
                alarmType: selectedAlarmType,
                isActive: selectedFilterType != .onlyPassiveAlarms
            ),
            AlarmHistoryItem(
                id: "2",
                title: "Titreşim Anomalisi",
                expert: "Ahmet Yılmaz",
                startDate: "18.06.2025 15:30:45",
                asset: "Pompa",
                point: "Bearing",
                alarmType: .vibrationRMS,
                isActive: selectedFilterType != .onlyPassiveAlarms
            ),
            AlarmHistoryItem(
                id: "3",
                title: "Sıcaklık Yüksekliği",
                expert: "Mehmet Kaya",
                startDate: "17.06.2025 09:15:22",
                asset: "Kompresör",
                point: "Outlet",
                alarmType: .temperature,
                isActive: false
            )
        ]
        
        // Filter based on alarm type
        let filteredByType = selectedAlarmType == .allAlarms ? 
            mockItems : mockItems.filter { $0.alarmType == selectedAlarmType }
        
        // Filter based on active/passive
        let filteredByStatus: [AlarmHistoryItem]
        switch selectedFilterType {
        case .allAlarms:
            filteredByStatus = filteredByType
        case .onlyActiveAlarms:
            filteredByStatus = filteredByType.filter { $0.isActive }
        case .onlyPassiveAlarms:
            filteredByStatus = filteredByType.filter { !$0.isActive }
        }
        
        return filteredByStatus
    }
    
    private func createMockDiagnosisData() -> [DiagnosisHistoryItem] {
        return [
            DiagnosisHistoryItem(
                id: "1",
                title: "Dengesizlik",
                expert: "Umut Çetin",
                startDate: "19.06.2025 20:56:57",
                asset: "Motor",
                point: "Drive end"
            ),
            DiagnosisHistoryItem(
                id: "2",
                title: "Hizalama Problemi",
                expert: "Ali Veli",
                startDate: "18.06.2025 14:22:33",
                asset: "Pompa",
                point: "Coupling"
            )
        ]
    }
}

// MARK: - Data Models

struct AlarmHistoryItem: Identifiable {
    let id: String
    let title: String
    let expert: String
    let startDate: String
    let asset: String
    let point: String
    let alarmType: AlarmType
    let isActive: Bool
}

struct DiagnosisHistoryItem: Identifiable {
    let id: String
    let title: String
    let expert: String
    let startDate: String
    let asset: String
    let point: String
} 
