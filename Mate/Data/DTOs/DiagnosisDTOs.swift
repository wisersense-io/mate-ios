import Foundation

// MARK: - Last Diagnosis Request DTO

struct LastDiagnosisRequestDTO: Codable {
    let systemId: String
    let dateType: String
    
    init(systemId: String, dateType: Int) {
        self.systemId = systemId
        self.dateType = String(dateType)
    }
}

// MARK: - Last Diagnosis Response DTO

struct LastDiagnosisResponseDTO: Codable {
    let level: Int
    let type: Int
}

// MARK: - Domain Models

struct LastDiagnosis {
    let level: Int
    let type: Int
    
    var levelDescription: String {
        switch level {
        case 1:
            return "Low"
        case 2:
            return "Medium"
        case 3:
            return "High"
        case 4:
            return "Critical"
        default:
            return "Unknown"
        }
    }
    
    var levelColor: String {
        switch level {
        case 1:
            return "#28a745" // Green
        case 2:
            return "#ffc107" // Yellow
        case 3:
            return "#fd7e14" // Orange
        case 4:
            return "#dc3545" // Red
        default:
            return "#6c757d" // Gray
        }
    }
    
    var typeDescription: String {
        switch type {
        case 1:
            return "Vibration"
        case 2:
            return "Temperature"
        case 3:
            return "Acoustic"
        case 4:
            return "Magnetic"
        case 5:
            return "Proximity"
        default:
            return "Unknown"
        }
    }
    
    var iconName: String {
        switch type {
        case 1:
            return "waveform" // Vibration
        case 2:
            return "thermometer" // Temperature
        case 3:
            return "speaker.wave.2" // Acoustic
        case 4:
            return "magnet" // Magnetic
        case 5:
            return "location" // Proximity
        default:
            return "questionmark.circle"
        }
    }
}

// MARK: - DTO to Domain Mappers

extension LastDiagnosisResponseDTO {
    func toDomain() -> LastDiagnosis {
        return LastDiagnosis(
            level: level,
            type: type
        )
    }
}

extension Array where Element == LastDiagnosisResponseDTO {
    func toDomain() -> [LastDiagnosis] {
        return map { $0.toDomain() }
    }
}
