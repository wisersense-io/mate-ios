import Foundation

// MARK: - System API Response
struct SystemsResponse: Codable {
    let data: [System]
}

// MARK: - System Model (Simplified)
struct System: Codable {
    let id: String
    let organizationId: String
    let tenantId: String
    let key: String
    let description: String
    let info: String
    let healthScore: Double
    let healthScoreAt: String
    let weightCoefficient: Double
    let alarmType: Int
    let alarmStage: Int
    let hasActiveDiagnos: Int  // API sends 0/1 instead of Bool
    
    // Coding keys for JSON mapping
    enum CodingKeys: String, CodingKey {
        case id
        case organizationId
        case tenantId
        case key
        case description
        case info
        case healthScore
        case healthScoreAt
        case weightCoefficient
        case alarmType
        case alarmStage
        case hasActiveDiagnos
    }
    
    // Custom decoder to handle different data types and optional fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decode(String.self, forKey: .id)
        organizationId = try container.decode(String.self, forKey: .organizationId)
        tenantId = try container.decode(String.self, forKey: .tenantId)
        key = try container.decode(String.self, forKey: .key)
        description = try container.decode(String.self, forKey: .description)
        info = try container.decode(String.self, forKey: .info)
        
        // Optional fields with defaults
        healthScoreAt = (try? container.decode(String.self, forKey: .healthScoreAt)) ?? ""
        
        // Handle healthScore (might be String, Double, or missing)
        if let healthScoreDouble = try? container.decode(Double.self, forKey: .healthScore) {
            healthScore = healthScoreDouble
        } else if let healthScoreString = try? container.decode(String.self, forKey: .healthScore) {
            healthScore = Double(healthScoreString) ?? 0.0
        } else {
            healthScore = 0.0  // Default value if missing
        }
        
        // Handle weightCoefficient (might be String, Double, or missing)
        if let weightDouble = try? container.decode(Double.self, forKey: .weightCoefficient) {
            weightCoefficient = weightDouble
        } else if let weightString = try? container.decode(String.self, forKey: .weightCoefficient) {
            weightCoefficient = Double(weightString) ?? 1.0
        } else {
            weightCoefficient = 1.0  // Default value if missing
        }
        
        // Handle alarmType (might be String, Int, or missing)
        if let alarmTypeInt = try? container.decode(Int.self, forKey: .alarmType) {
            alarmType = alarmTypeInt
        } else if let alarmTypeString = try? container.decode(String.self, forKey: .alarmType) {
            alarmType = Int(alarmTypeString) ?? 0
        } else {
            alarmType = 0  // Default value if missing
        }
        
        // Handle alarmStage (might be String, Int, or missing)
        if let alarmStageInt = try? container.decode(Int.self, forKey: .alarmStage) {
            alarmStage = alarmStageInt
        } else if let alarmStageString = try? container.decode(String.self, forKey: .alarmStage) {
            alarmStage = Int(alarmStageString) ?? 0
        } else {
            alarmStage = 0  // Default value if missing
        }
        
        // Handle hasActiveDiagnos (might be Bool, Int, String, or missing)
        if let hasActiveDiagnosInt = try? container.decode(Int.self, forKey: .hasActiveDiagnos) {
            hasActiveDiagnos = hasActiveDiagnosInt
        } else if let hasActiveDiagnosBool = try? container.decode(Bool.self, forKey: .hasActiveDiagnos) {
            hasActiveDiagnos = hasActiveDiagnosBool ? 1 : 0
        } else if let hasActiveDiagnosString = try? container.decode(String.self, forKey: .hasActiveDiagnos) {
            hasActiveDiagnos = Int(hasActiveDiagnosString) ?? 0
        } else {
            hasActiveDiagnos = 0  // Default value if missing
        }
    }
    
    // Custom encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(organizationId, forKey: .organizationId)
        try container.encode(tenantId, forKey: .tenantId)
        try container.encode(key, forKey: .key)
        try container.encode(description, forKey: .description)
        try container.encode(info, forKey: .info)
        try container.encode(healthScore, forKey: .healthScore)
        try container.encode(healthScoreAt, forKey: .healthScoreAt)
        try container.encode(weightCoefficient, forKey: .weightCoefficient)
        try container.encode(alarmType, forKey: .alarmType)
        try container.encode(alarmStage, forKey: .alarmStage)
        try container.encode(hasActiveDiagnos, forKey: .hasActiveDiagnos)
    }
    
    // Standard initializer for sample data
    init(id: String, organizationId: String, tenantId: String, key: String, description: String, 
         info: String, healthScore: Double, healthScoreAt: String, weightCoefficient: Double, 
         alarmType: Int, alarmStage: Int, hasActiveDiagnos: Int) {
        self.id = id
        self.organizationId = organizationId
        self.tenantId = tenantId
        self.key = key
        self.description = description
        self.info = info
        self.healthScore = healthScore
        self.healthScoreAt = healthScoreAt
        self.weightCoefficient = weightCoefficient
        self.alarmType = alarmType
        self.alarmStage = alarmStage
        self.hasActiveDiagnos = hasActiveDiagnos
    }
    
    // Computed properties for easier access
    var hasAlarm: Bool {
        return alarmType > 0
    }
    
    var hasDiagnosis: Bool {
        return hasActiveDiagnos > 0  // Convert Int to Bool
    }
    
    var parsedInfo: SystemInfo? {
        guard let data = info.data(using: .utf8) else { 
            print("❌ System.parsedInfo: Could not convert info string to Data for system: \(key)")
            return nil 
        }
        
        do {
            return try JSONDecoder().decode(SystemInfo.self, from: data)
        } catch {
            print("❌ System.parsedInfo: JSON decode error for system '\(key)': \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("❌ Type mismatch: Expected \(type) at \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("❌ Value not found: \(type) at \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("❌ Key not found: \(key) at \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("❌ Data corrupted at \(context.codingPath)")
                @unknown default:
                    print("❌ Unknown decoding error")
                }
            }
            return nil
        }
    }
}

// MARK: - DeviceInfo Model
struct DeviceInfo {
    let deviceId: String
    let macAddress: String
    let systemId: String
    let connectionState: DeviceConnectionState
    let runningState: AssetRunningState
}

// MARK: - Device States
// Using enums from WebSocketModels.swift to avoid duplication

// MARK: - System Info (for parsing JSON)
struct SystemInfo: Codable {
    let icon: String
    let system: SystemDetails
    let assets: [Asset]
}

struct SystemDetails: Codable {
    let id: String
    let key: String
    let description: String
    let weightCoefficient: Double
    let onOffLimit: Double
}

struct Asset: Codable {
    let id: String
    let group: Int?
    let type: Int?
    let properties: AssetProperties
    let points: [Point]
    let components: [Component]
    
    enum CodingKeys: String, CodingKey {
        case id, group, type, properties, points, components
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        
        // Flexible decoding for group field
        if let groupInt = try? container.decode(Int.self, forKey: .group) {
            self.group = groupInt
        } else if let groupString = try? container.decode(String.self, forKey: .group),
                  let groupInt = Int(groupString) {
            self.group = groupInt
        } else {
            self.group = nil
        }
        
        // Flexible decoding for type field
        if let typeInt = try? container.decode(Int.self, forKey: .type) {
            self.type = typeInt
        } else if let typeString = try? container.decode(String.self, forKey: .type),
                  let typeInt = Int(typeString) {
            self.type = typeInt
        } else {
            self.type = nil
        }
        
        self.properties = try container.decode(AssetProperties.self, forKey: .properties)
        self.points = try container.decode([Point].self, forKey: .points)
        self.components = try container.decode([Component].self, forKey: .components)
    }
}

struct AssetProperties: Codable {
    let type: Int
    let speedType: Int?
    let speed: Int?
    let minSpeed: Int?
    let maxSpeed: Int?
    
    enum CodingKeys: String, CodingKey {
        case type, speedType, speed, minSpeed, maxSpeed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Flexible decoding for type field (can be Int or String)
        if let typeInt = try? container.decode(Int.self, forKey: .type) {
            self.type = typeInt
        } else if let typeString = try? container.decode(String.self, forKey: .type),
                  let typeInt = Int(typeString) {
            self.type = typeInt
        } else {
            self.type = 0 // Default value
        }
        
        // Flexible decoding for speedType
        if let speedTypeInt = try? container.decode(Int.self, forKey: .speedType) {
            self.speedType = speedTypeInt
        } else if let speedTypeString = try? container.decode(String.self, forKey: .speedType),
                  let speedTypeInt = Int(speedTypeString) {
            self.speedType = speedTypeInt
        } else {
            self.speedType = nil
        }
        
        // Flexible decoding for speed
        if let speedInt = try? container.decode(Int.self, forKey: .speed) {
            self.speed = speedInt
        } else if let speedString = try? container.decode(String.self, forKey: .speed),
                  let speedInt = Int(speedString) {
            self.speed = speedInt
        } else {
            self.speed = nil
        }
        
        // Flexible decoding for minSpeed
        if let minSpeedInt = try? container.decode(Int.self, forKey: .minSpeed) {
            self.minSpeed = minSpeedInt
        } else if let minSpeedString = try? container.decode(String.self, forKey: .minSpeed),
                  let minSpeedInt = Int(minSpeedString) {
            self.minSpeed = minSpeedInt
        } else {
            self.minSpeed = nil
        }
        
        // Flexible decoding for maxSpeed
        if let maxSpeedInt = try? container.decode(Int.self, forKey: .maxSpeed) {
            self.maxSpeed = maxSpeedInt
        } else if let maxSpeedString = try? container.decode(String.self, forKey: .maxSpeed),
                  let maxSpeedInt = Int(maxSpeedString) {
            self.maxSpeed = maxSpeedInt
        } else {
            self.maxSpeed = nil
        }
    }
}

struct Point: Codable {
    let id: String
    let pointType: Int
    let index: Int
    let properties: PointProperties
    let devices: [Device]
    let speed: Double?
    let minSpeed: Double?
    let maxSpeed: Double?
}

struct PointProperties: Codable {
    let pointType: String
    let rmsWarningLimit: Double
    let rmsDangerLimit: Double
    let vRmsWarningLimit: Double
    let vRmsDangerLimit: Double
    let cfWarningLimit: Double
    let cfDangerLimit: Double
    
    // These fields are not present in the actual API response, so making them optional
    let rmsRetryCount: Int?
    let rmsAlarmActive: Int?
    let vRmsRetryCount: Int?
    let vRmsAlarmActive: Int?
    let cfRetryCount: Int?
    let cfAlarmActive: Int?
    let acousticRMSRetryCount: Int?
    let acousticRMSAlarmActive: Int?
    let acousticCFRetryCount: Int?
    let acousticCFAlarmActive: Int?
    let magneticRMSRetryCount: Int?
    let magneticRMSAlarmActive: Int?
    let magneticCFRetryCount: Int?
    let magneticCFAlarmActive: Int?
    let proximityP2PRetryCount: Int?
    let proximityP2PAlarmActive: Int?
    let temperatureRetryCount: Int?
    let temperatureAlarmActive: Int?
}

struct Device: Codable {
    let id: String
    let imei: String
    let macAddress: String
    let deviceModel: Int
    let inactivityTimeout: Int
    let deviceId: String
    let verticalAxis: Int
    let horizontalAxis: Int
    let axialAxis: Int
}

struct Component: Codable {
    // Empty for now
}

// MARK: - Filter Enum
enum SystemFilterType: Int, CaseIterable {
    case all = 0
    case withAlarm = 1
    case withDiagnosis = 2
    case withFavorites = 3
    case inDanger = 4
    case inWarning = 5
    case inMonitoring = 6
    case inOk = 7
    
    var localizedTitle: String {
        switch self {
        case .all:
            return NSLocalizedString("key_all_systems", comment: "All systems")
        case .withAlarm:
            return NSLocalizedString("key_systems_with_alarm", comment: "Systems with alarm")
        case .withDiagnosis:
            return NSLocalizedString("key_systems_with_diagnosis", comment: "Systems with diagnosis")
        case .withFavorites:
            return NSLocalizedString("key_systems_with_favorites", comment: "Favorite systems")
        case .inDanger:
            return NSLocalizedString("key_systems_in_danger", comment: "Systems in danger")
        case .inWarning:
            return NSLocalizedString("key_systems_in_warning", comment: "Systems in warning")
        case .inMonitoring:
            return NSLocalizedString("key_systems_in_monitoring", comment: "Systems in monitoring")
        case .inOk:
            return NSLocalizedString("key_systems_in_ok", comment: "Healthy systems")
        }
    }
}

// MARK: - Device Helper Functions
extension Array where Element == System {
    func prepareDevices() -> [DeviceInfo] {
        var result: [DeviceInfo] = []
        
        for system in self {
            guard let systemInfo = system.parsedInfo else { continue }
            
            // Filter assets that have points
            let assetsWithPoints = systemInfo.assets.filter { $0.points.count > 0 }
            
            for asset in assetsWithPoints {
                // Filter points that have devices
                let pointsWithDevices = asset.points.filter { $0.devices.count > 0 }
                
                for point in pointsWithDevices {
                    for device in point.devices {
                        result.append(DeviceInfo(
                            deviceId: device.deviceId,
                            macAddress: device.macAddress,
                            systemId: system.id,
                            connectionState: DeviceConnectionState.none,
                            runningState: AssetRunningState.none
                        ))
                    }
                }
            }
        }
        
        return result
    }
}

// MARK: - Sample Data
extension System {
    static let sampleData: [System] = [
        System(
            id: "1",
            organizationId: "org1",
            tenantId: "tenant1",
            key: "PCW",
            description: "001",
            info: #"""
            {
                "icon": "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 50'><rect x='10' y='10' width='30' height='30' fill='#4CAF50'/><text x='50' y='30' font-family='Arial' font-size='16' fill='black'>PCW</text></svg>",
                "system": {
                    "id": "sys1",
                    "key": "PCW",
                    "description": "PCW System",
                    "weightCoefficient": 1.0,
                    "onOffLimit": 0.5
                },
                "assets": []
            }
            """#,
            healthScore: 85.0,
            healthScoreAt: "2024-01-15T10:30:00Z",
            weightCoefficient: 1.0,
            alarmType: 0,
            alarmStage: 0,
            hasActiveDiagnos: 0
        ),
        System(
            id: "fac4d508-a01a-0199-aa1b-35d398a6df53",
            organizationId: "org1",
            tenantId: "tenant1",
            key: "Fırın Ana Tahrik",
            description: "1",
            info: #"""
            {"icon":"<svg viewBox=\"0 0 397 137\"><svg assetGroup=\"0\" assetType=\"0\" x=\"0\" y=\"68\" width=\"95\" height=\"69\"><svg x=\"0\" y=\"5\" class=\"symbol\"><path d=\"M50.89,3.41c-2.13,0-3.86,1.76-3.86,3.93s1.73,3.93,3.86,3.93s3.86-1.76,3.86-3.93S53.02,3.41,50.89,3.41z M50.89,9.38 c-1.1,0-2-0.91-2-2.03s0.9-2.03,2-2.03s2,0.91,2,2.03S52,9.38,50.89,9.38z\"></path><path d=\"M61.19,3.41c-2.13,0-3.86,1.76-3.86,3.93s1.73,3.93,3.86,3.93s3.86-1.76,3.86-3.93S63.32,3.41,61.19,3.41z M61.19,9.38 c-1.1,0-2-0.91-2-2.03s0.9-2.03,2-2.03c1.1,0,2,0.91,2,2.03S62.3,9.38,61.19,9.38z\"></path><path d=\"M45.4,19.69c-8.18,0-14.84,6.77-14.84,15.09c0,8.32,6.66,15.09,14.84,15.09c8.18,0,14.84-6.77,14.84-15.09 C60.24,26.46,53.58,19.69,45.4,19.69z M45.4,47.98c-7.16,0-12.98-5.92-12.98-13.2c0-7.28,5.82-13.2,12.98-13.2 c7.16,0,12.98,5.92,12.98,13.2C58.38,42.06,52.55,47.98,45.4,47.98z\"></path></svg><svg x=\"0\" y=\"0\" pointType=\"1\" index=\"0\" class=\"point\" empty=\"false\"><path d=\"M8.4 0C9.120000000000001 0 9.73 0.06 10.34 0.2C12.07 0.6000000000000001 13.56 1.42 14.77 2.7C15.49 3.47 16.05 4.34 16.43 5.300000000000001C16.62 5.780000000000001 16.759999999999998 6.280000000000001 16.86 6.790000000000001C17 7.530000000000001 17.04 8.270000000000001 16.96 9.010000000000002C16.84 10.030000000000001 16.55 11.000000000000002 16.16 11.940000000000001C15.55 13.410000000000002 14.73 14.770000000000001 13.81 16.07C12.89 17.37 11.89 18.61 10.81 19.78C10.16 20.48 9.48 21.150000000000002 8.81 21.84C8.610000000000001 22.05 8.42 22.04 8.21 21.84C7.000000000000001 20.67 5.860000000000001 19.44 4.790000000000001 18.15C4.070000000000001 17.279999999999998 3.390000000000001 16.369999999999997 2.760000000000001 15.429999999999998C2.0600000000000014 14.389999999999997 1.440000000000001 13.309999999999999 0.9400000000000011 12.159999999999998C0.660000000000001 11.519999999999998 0.43000000000000105 10.859999999999998 0.260000000000001 10.189999999999998C0.09 9.48 -0.02 8.75 0 8.01C0.02 7.569999999999999 0.07 7.13 0.16 6.6899999999999995C0.42000000000000004 5.43 0.9400000000000001 4.279999999999999 1.75 3.2599999999999993C2.66 2.11 3.8 1.25 5.17 0.67C5.75 0.43000000000000005 6.359999999999999 0.26000000000000006 6.98 0.13C7.49 0.04 7.99 0.02 8.4 0ZM8.43 12.03C10.559999999999999 12.09 12.35 10.44 12.4 8.36C12.46 6.319999999999999 10.84 4.52 8.58 4.469999999999999C6.46 4.42 4.7 6.03 4.61 8.08C4.51 10.2 6.21 12 8.43 12.03Z \"></path></svg></svg></svg>","system":{"id":"fac4d508-a01a-0199-aa1b-35d398a6df53","key":"Fırın Ana Tahrik","description":"1","weightCoefficient":10,"onOffLimit":0.10000000149011612},"assets":[{"id":"7f6867e2-91fb-8fb3-5529-11be330bb0c1","group":0,"type":0,"properties":{"type":0,"speed":1500,"maxSpeed":1600,"minSpeed":900,"speedType":1},"points":[{"id":"93cc1c14-82a8-8611-df63-44856236c4d1","pointType":1,"index":0,"properties":{"pointType":"Non drive end","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[{"id":"8a9e70aa-e35e-471c-8538-cf82250a146c","imei":"E831CDA09830","macAddress":"E831CDA09830","deviceModel":2,"inactivityTimeout":60,"deviceId":"Motoru Arka","verticalAxis":0,"horizontalAxis":2,"axialAxis":1}]},{"id":"fea66213-5c48-f4f8-d9f9-2974b3295229","pointType":0,"index":1,"properties":{"pointType":"Drive end","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[{"id":"9f125a69-5a55-45ed-a910-c041c8c3e11b","imei":"E831CDA25988","macAddress":"E831CDA25988","deviceModel":2,"inactivityTimeout":60,"deviceId":"Motoru Ön","verticalAxis":0,"horizontalAxis":2,"axialAxis":1}]}],"components":[]},{"id":"06a16a28-8c7e-10c6-952f-35c454ebd660","group":2,"type":0,"properties":{"type":0},"points":[],"components":[]},{"id":"d712fa57-493d-bc90-7355-b302875bc925","group":5,"type":1,"properties":{"type":1},"points":[{"id":"d59621f2-fcaf-9d48-6178-20b46ec6cf11","pointType":2,"index":0,"properties":{"pointType":"1st shaft DE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[{"id":"62b9df2c-d677-4380-adb3-6a26868aa992","imei":"E831CDA16B44","macAddress":"E831CDA16B44","deviceModel":2,"inactivityTimeout":60,"deviceId":"Redüktör Giriş","verticalAxis":0,"horizontalAxis":2,"axialAxis":1}]},{"id":"c6c32d5f-6a33-775f-edb5-ebe0b26481c2","pointType":7,"index":1,"properties":{"pointType":"2nd shaft DE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[]},{"id":"b02c7964-359d-8a44-a188-291bb67b6d1d","pointType":12,"index":2,"properties":{"pointType":"3rd shaft DE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[]},{"id":"108f6602-adbd-1d86-9182-8db4c2db1112","pointType":3,"index":3,"properties":{"pointType":"1st shaft NDE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[]},{"id":"fa3b99d2-6aba-c0d5-9a05-2f6373f0d365","pointType":8,"index":4,"properties":{"pointType":"2nd shaft NDE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[]},{"id":"f75c5860-58ca-16a0-fdb1-18fb89a668c1","pointType":13,"index":5,"properties":{"pointType":"3rd shaft NDE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[{"id":"395379c7-7320-4543-bbb5-e176891fc42a","imei":"E831CDA170E4","macAddress":"E831CDA170E4","deviceModel":2,"inactivityTimeout":60,"deviceId":"Redüktör Çıkış","verticalAxis":0,"horizontalAxis":2,"axialAxis":1}]}],"components":[]},{"id":"fdb7a067-14ae-9adf-922d-86331eb4d7d2","group":8,"type":0,"properties":{"type":0},"points":[{"id":"c0ffc2f6-ad60-11a0-f85a-cb16cffcc32d","pointType":22,"index":0,"properties":{"pointType":"Pinion DE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[]},{"id":"dad14852-2571-04bc-f16a-e3960bf3b0fe","pointType":23,"index":1,"properties":{"pointType":"Pinion NDE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[]},{"id":"e9774e68-22cc-7385-02de-91248da7bbfd","pointType":24,"index":2,"properties":{"pointType":"Mill DE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[]},{"id":"62b8f40f-2bdf-884d-6ba2-773e179d8fb8","pointType":25,"index":3,"properties":{"pointType":"Mill NDE","cfDangerLimit":6.5,"cfWarningLimit":4.5,"rmsDangerLimit":0.7,"rmsWarningLimit":0.5,"vRmsDangerLimit":5,"vRmsWarningLimit":4},"devices":[]}],"components":[]}]}
            """#,
            healthScore: 72.0,
            healthScoreAt: "2024-01-15T09:20:00Z",
            weightCoefficient: 10.0,
            alarmType: 1,
            alarmStage: 1,
            hasActiveDiagnos: 1
        )
    ]
} 
