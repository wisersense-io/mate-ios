import Foundation
import Combine
import SwiftUI

@MainActor
class SystemsViewModel: ObservableObject {
    @Published var systems: [System] = []
    @Published var filteredSystems: [System] = []
    @Published var devices: [DeviceInfo] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var selectedFilter: SystemFilterType = .all
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    @Published var searchText = ""
    
    // MARK: - SignalR Properties
    @Published var aliveSystems: Set<String> = []
    @Published var connectedDevices: Set<String> = []
    @Published var signalRConnectionState: SignalRConnectionState = .disconnected
    @Published var isSignalRConnected: Bool = false
    
    private let systemUseCase: SystemUseCase
    private let organizationUseCase: OrganizationUseCaseProtocol
    private let signalRManager: SignalRManagerProtocol
    private let pageSize = 20
    private var currentPage = 0
    private var currentOrganizationId: String?
    
    init(systemUseCase: SystemUseCase, organizationUseCase: OrganizationUseCaseProtocol, signalRManager: SignalRManagerProtocol? = nil) {
        self.systemUseCase = systemUseCase
        self.organizationUseCase = organizationUseCase
        self.signalRManager = signalRManager ?? SignalRManager.shared
        
        setupSignalRObservation()
    }
    
    // MARK: - Data Loading
    
    func loadSystems() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            guard let organizationId = getOrganizationId() else {
                errorMessage = "Organization not found"
                isLoading = false
                return
            }
            
            currentOrganizationId = organizationId
            currentPage = 0
            
            let newSystems = try await systemUseCase.getSystems(
                organizationId: organizationId,
                filter: selectedFilter,
                skip: 0,
                take: pageSize
            )
            
            systems = newSystems
            hasMorePages = newSystems.count >= pageSize
            applyFilter()
            
            // Prepare devices from systems
            devices = systemUseCase.prepareDevices(from: systems)
            print("📱 SystemsViewModel: Prepared \(devices.count) devices from \(systems.count) systems")
            
            // Send devices to SignalR if connected
            if isSignalRConnected {
                await sendDevicesToSignalR()
            }
            
        } catch {
            errorMessage = error.localizedDescription
            systems = []
            devices = []
        }
        
        isLoading = false
    }
    
    func loadMoreSystems() async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        
        do {
            guard let organizationId = currentOrganizationId else {
                return
            }
            
            let skip = (currentPage + 1) * pageSize
            let newSystems = try await systemUseCase.getSystems(
                organizationId: organizationId,
                filter: selectedFilter,
                skip: skip,
                take: pageSize
            )
            
            systems.append(contentsOf: newSystems)
            currentPage += 1
            hasMorePages = newSystems.count >= pageSize
            applyFilter()
            
            // Update devices
            devices = systemUseCase.prepareDevices(from: systems)
            print("📱 SystemsViewModel: Updated devices - now \(devices.count) devices from \(systems.count) systems")
            
            // Send updated devices to SignalR if connected
            if isSignalRConnected {
                await sendDevicesToSignalR()
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoadingMore = false
    }
    
    func refreshSystems() async {
        currentPage = 0
        hasMorePages = true
        await loadSystems()
    }
    
    // MARK: - Filtering
    
    func filterChanged(_ filter: SystemFilterType) {
        selectedFilter = filter
        Task {
            await loadSystems()
        }
    }
    
    private func applyFilter() {
        // First apply selected filter
        var tempSystems: [System]
        
        switch selectedFilter {
        case .all:
            tempSystems = systems
        case .withAlarm:
            tempSystems = systems.filter { $0.hasAlarm }
        case .withDiagnosis:
            tempSystems = systems.filter { $0.hasDiagnosis }
        case .withFavorites:
            // Implement favorites logic when available
            tempSystems = systems
        case .inDanger:
            tempSystems = systems.filter { $0.alarmType == 2 }
        case .inWarning:
            tempSystems = systems.filter { $0.alarmType == 1 }
        case .inMonitoring:
            tempSystems = systems.filter { $0.alarmType == 0 && $0.healthScore > 0 }
        case .inOk:
            tempSystems = systems.filter { $0.alarmType == 0 && $0.healthScore >= 80 }
        }
        
        // Then apply search filter if search text is not empty
        if !searchText.isEmpty {
            tempSystems = tempSystems.filter { system in
                system.key.localizedCaseInsensitiveContains(searchText) ||
                system.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredSystems = tempSystems
    }
    
    // MARK: - Search
    
    func searchSystems(query: String) {
        searchText = query
        applyFilter()
    }
    
    // MARK: - Device Management
    
    func getDevicesForSystem(_ systemId: String) -> [DeviceInfo] {
        return devices.filter { $0.systemId == systemId }
    }
    
    func getDeviceCount() -> Int {
        return devices.count
    }
    
    // MARK: - Organization Management
    
    private func getOrganizationId() -> String? {
        // organizationUseCase.getSelectedOrganization() is synchronous and non-throwing
        return organizationUseCase.getSelectedOrganization()
    }
    
    // MARK: - Organization Change Detection
    
    func checkAndRefreshIfOrganizationChanged() async -> Bool {
        if let newOrganizationId = getOrganizationId(),
           newOrganizationId != currentOrganizationId {
            await loadSystems()
            return true // Data was refreshed
        }
        return false // No refresh needed
    }
    
    func getSystemsCount() -> Int {
        return filteredSystems.count
    }
    
    func getAssetsCount() -> Int {
        return filteredSystems.compactMap { $0.parsedInfo }.reduce(0) { $0 + $1.assets.count }
    }
    
    func getActiveDevicesCount() -> Int {
        return filteredSystems.compactMap { $0.parsedInfo }.reduce(0) { systemSum, system in
            systemSum + system.assets.reduce(0) { assetSum, asset in
                assetSum + asset.points.reduce(0) { pointSum, point in
                    pointSum + point.devices.count
                }
            }
        }
    }
    
    // MARK: - SignalR Management
    
    private func setupSignalRObservation() {
        // Observe SignalR connection state
        signalRManager.onReceiveMessage { [weak self] message in
            Task { @MainActor in
                self?.handleWebSocketMessage(message)
            }
        }
        
        // TODO: Observe SignalR published properties when real implementation is added
        // This will be implemented when SignalR package is integrated
    }
    
    func startSignalRConnection() async {
        do {
            try await signalRManager.startConnection()
            signalRConnectionState = signalRManager.connectionState
            isSignalRConnected = signalRManager.isConnected
            
            // Send devices to SignalR after connection is established
            if !devices.isEmpty {
                await sendDevicesToSignalR()
            }
            
        } catch {
            print("❌ SystemsViewModel: SignalR connection failed - \(error.localizedDescription)")
            errorMessage = "SignalR connection failed: \(error.localizedDescription)"
        }
    }
    
    func stopSignalRConnection() async {
        await signalRManager.stopConnection()
        signalRConnectionState = signalRManager.connectionState
        isSignalRConnected = signalRManager.isConnected
        
        // Clear state
        aliveSystems.removeAll()
        connectedDevices.removeAll()
    }
    
    private func sendDevicesToSignalR() async {
        guard !devices.isEmpty else {
            print("⚠️ SystemsViewModel: No devices to send to SignalR")
            return
        }
        
        await signalRManager.sendDevices(devices)
        print("📡 SystemsViewModel: Sent \(devices.count) devices to SignalR")
    }
    
    private func handleWebSocketMessage(_ message: WebSocketMessage) {
        print("📨 SystemsViewModel: Received WebSocket message - Type: \(message.type), SystemId: \(message.data.device.systemId), State: \(message.data.state)")
        
        switch message.type {
        case .assetRunningStateChanged:
            handleAssetRunningStateChanged(message.data)
        case .deviceConnectionStateChanged:
            handleDeviceConnectionStateChanged(message.data)
        default:
            print("⚠️ SystemsViewModel: Unhandled message type: \(message.type)")
        }
    }
    
    private func handleAssetRunningStateChanged(_ data: WebSocketMessageData) {
        let systemId = data.device.systemId
        let state = data.state
        
        // Update alive systems based on running state
        if state == AssetRunningState.running.rawValue {
            aliveSystems.insert(systemId)
            print("🟢 SystemsViewModel: System \(systemId) is now RUNNING")
        } else {
            aliveSystems.remove(systemId)
            print("🔴 SystemsViewModel: System \(systemId) is now STOPPED")
        }
    }
    
    private func handleDeviceConnectionStateChanged(_ data: WebSocketMessageData) {
        let systemId = data.device.systemId
        let state = data.state
        
        // Update connected devices based on connection state
        if state == DeviceConnectionState.connected.rawValue {
            connectedDevices.insert(systemId)
            print("🟢 SystemsViewModel: Device \(systemId) is now CONNECTED")
        } else {
            connectedDevices.remove(systemId)
            print("🔴 SystemsViewModel: Device \(systemId) is now DISCONNECTED")
        }
    }
    
    // MARK: - System State Helpers
    
    func isSystemAlive(_ systemId: String) -> Bool {
        return aliveSystems.contains(systemId)
    }
    
    func isDeviceConnected(_ systemId: String) -> Bool {
        return connectedDevices.contains(systemId)
    }
    
    func getSignalRStats() -> (alive: Int, connected: Int) {
        return (alive: aliveSystems.count, connected: connectedDevices.count)
    }
} 
