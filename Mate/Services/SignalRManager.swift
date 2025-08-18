import Foundation
import Combine
import SignalRClient

protocol SignalRManagerProtocol {
    func startConnection() async throws
    func stopConnection() async
    func sendDevices(_ devices: [DeviceInfo]) async
    func signinAsync(_ userId: String) async
    func onReceiveMessage(_ callback: @escaping (WebSocketMessage) -> Void)
    var connectionState: SignalRConnectionState { get }
    var isConnected: Bool { get }
}

@MainActor
class SignalRManager: SignalRManagerProtocol, ObservableObject {
    
    // MARK: - Singleton
    static let shared = SignalRManager()
    
    // MARK: - Properties
    @Published var connectionState: SignalRConnectionState = .disconnected
    @Published var errorMessage: String?
    
    var isConnected: Bool {
        return connectionState == .connected
    }
    
    private var hubConnection: SignalRClient.HubConnection?
    private var gatewayURL = "https://mategateway.fizix.ai/gateway"
    private var messageCallback: ((WebSocketMessage) -> Void)?
    private var reconnectTimer: Timer?
    
    // MARK: - Initialization
    private init() {
        Task {
            await setupConnection()
        }
    }
    
    // MARK: - Connection Setup
    private func setupConnection() async {
        let accessToken = await getAccessToken()
        gatewayURL += "?access_token=\(accessToken)"
        print("Gateway Url: \(gatewayURL)")
        guard let url = URL(string: gatewayURL) else {
            print("❌ SignalR: Invalid gateway URL")
            return
        }
        
        // Microsoft SignalR Swift API - Basic setup
        hubConnection = HubConnectionBuilder()
            .withUrl(url: gatewayURL)
            .withAutomaticReconnect()
            .withLogLevel(logLevel: .debug)
            .build()
    }
    
    // MARK: - Connection Management
    func startConnection() async throws {
        guard connectionState != .connected else { return }
        
        connectionState = .connecting
        errorMessage = nil
        
        do {
            // Start actual SignalR connection
            try await hubConnection?.start()
            
            connectionState = .connected
            
            setupMessageHandlers()
            
            print("🔗 SignalR: Connected to gateway")
            
        } catch {
            connectionState = .disconnected
            errorMessage = error.localizedDescription
            
            print("❌ SignalR: Connection failed - \(error.localizedDescription)")
            
            // Schedule reconnection
            scheduleReconnection()
            throw error
        }
    }
    
    func stopConnection() async {
        guard connectionState != .disconnected else { return }
        
        connectionState = .disconnecting
        
        // Stop actual SignalR connection
        try? await hubConnection?.stop()
        
        connectionState = .disconnected
        
        cancelReconnectionTimer()
        
        print("🔗 SignalR: Disconnected from gateway")
    }
    
    // MARK: - Message Handling
    private func setupMessageHandlers() {
        guard let hubConnection = hubConnection else { return }
        
        // Setup SignalR message handlers - Microsoft SignalR Swift API
        Task {
            // Handle device asset state changes
            await hubConnection.on("onDeviceAssetStateChanged") { [weak self] (device: WebSocketDevice, state: Int) in
                let message = WebSocketMessage(
                    type: .assetRunningStateChanged,
                    data: WebSocketMessageData(device: device, state: state)
                )
                await MainActor.run {
                    self?.messageCallback?(message)
                }
            }
            
            // Handle device connection state events
            await hubConnection.on("onDeviceConnectionStateEvent") { [weak self] (device: WebSocketDevice, state: Int) in
                let message = WebSocketMessage(
                    type: .deviceConnectionStateChanged,
                    data: WebSocketMessageData(device: device, state: state)
                )
                await MainActor.run {
                    self?.messageCallback?(message)
                }
            }
            
            // Handle device connection state changes
            await hubConnection.on("onDeviceConnectionStateChanged") { [weak self] (device: WebSocketDevice, state: Int) in
                let message = WebSocketMessage(
                    type: .deviceConnectionStateChanged,
                    data: WebSocketMessageData(device: device, state: state)
                )
                await MainActor.run {
                    self?.messageCallback?(message)
                }
            }
        }
    }
    
    func onReceiveMessage(_ callback: @escaping (WebSocketMessage) -> Void) {
        messageCallback = callback
    }
    
    // MARK: - SignIn
    func signinAsync(_ userId: String) async {
        guard isConnected else {
            print("SignalR: Cannot signin - not connected")
            return
        }
        do {
            try await hubConnection?.invoke(method: "SignInAsync", arguments: userId)
        }
        catch {
            print("⚠️ SignalR: Error signing in: \(error)")
        }
        
    }
    
    // MARK: - Send Messages
    func sendDevices(_ devices: [DeviceInfo]) async {
        guard isConnected else {
            print("⚠️ SignalR: Cannot send devices - not connected")
            return
        }
        
        do {
            let userId = UserSessionManager.shared.currentUser?.id
            if (userId != nil) {
                print("UserId: \(userId!)")
            } else {
                print("UserId is nil")
            }
            try await hubConnection?.invoke(method: "SignInAsync", arguments: userId!)
            // Convert DeviceInfo to WebSocketDevice format
            let webSocketDevices = devices.map { device in
                WebSocketDevice(
                    systemId: device.systemId,
                    deviceId: device.deviceId,
                    macAddress: device.macAddress
                )
            }
            
            print("📡 SignalR: Sending \(webSocketDevices.count) devices to gateway")
            
            // Send actual SignalR message - Microsoft SignalR Swift API
            try await hubConnection?.invoke(method: "RegisterDevicesAsync", arguments: webSocketDevices)
            
            print("✅ SignalR: Successfully sent devices to gateway")
            
        } catch {
            print("❌ SignalR: Failed to send devices - \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Reconnection Logic
    private func scheduleReconnection() {
        cancelReconnectionTimer()
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                try? await self?.startConnection()
            }
        }
    }
    
    private func cancelReconnectionTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    // MARK: - Token Management
    private func getAccessToken() async -> String {
        // Get access token from TokenStorageService
        return UserDefaultsTokenStorageService().getToken()?.accessToken ?? ""
    }
    
    // MARK: - Cleanup
    deinit {
        Task {
            await stopConnection()
        }
    }
}

// MARK: - SignalR Implementation Complete
// Using Microsoft SignalR Swift package: https://github.com/dotnet/signalr-client-swift 
