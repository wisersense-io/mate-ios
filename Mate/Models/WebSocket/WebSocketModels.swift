import Foundation

// MARK: - WebSocket Message Types

enum GWayMessageType: Int, CaseIterable, Codable {
    case none = -1
    case identity = 0
    case registerDevice = 2
    case deviceConnectionStateChanged = 10
    case assetRunningStateChanged = 11
}

// MARK: - WebSocket Message Models

struct WebSocketMessage: Codable {
    let type: GWayMessageType
    let data: WebSocketMessageData
}

struct WebSocketMessageData: Codable {
    let device: WebSocketDevice
    let state: Int
}

struct WebSocketDevice: Codable {
    let systemId: String
    let deviceId: String?
    let macAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case systemId
        case deviceId
        case macAddress
    }
}

// MARK: - Connection State Enums

enum SignalRConnectionState: Int {
    case disconnected = 0
    case connecting = 1
    case connected = 2
    case disconnecting = 3
}

// MARK: - Device State Types

enum DeviceConnectionState: Int {
    case none = -1
    case disconnected = 0
    case connected = 1
}

enum AssetRunningState: Int {
    case none = -1
    case stopped = 0
    case running = 1
}
