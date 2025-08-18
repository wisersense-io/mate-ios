import Foundation

// MARK: - Asset Group Enumeration

enum AssetGroup: Int, CaseIterable, Codable {
    case none = -1
    case motor = 0
    case turbine = 1
    case connection = 2
    case pump = 3
    case fan = 4
    case gearbox = 5
    case compressor = 6
    case blower = 7
    case mill = 8
    case alternator = 9
    case generator = 10
    case mixer = 11
    case roller = 12
    case shaft = 13
    case separator = 14
    case crusher = 15
    case spindle = 16
    case press = 17
    case device = 18
    case point = 19
    case system = 99
    
    var localizationKey: String {
        switch self {
        case .none:
            return "keyAssetGroupNone"
        case .motor:
            return "keyAssetGroupMotor"
        case .turbine:
            return "keyAssetGroupTurbine"
        case .connection:
            return "keyAssetGroupConnection"
        case .pump:
            return "keyAssetGroupPump"
        case .fan:
            return "keyAssetGroupFan"
        case .gearbox:
            return "keyAssetGroupGearbox"
        case .compressor:
            return "keyAssetGroupCompressor"
        case .blower:
            return "keyAssetGroupBlower"
        case .mill:
            return "keyAssetGroupMill"
        case .alternator:
            return "keyAssetGroupAlternator"
        case .generator:
            return "keyAssetGroupGenerator"
        case .mixer:
            return "keyAssetGroupMixer"
        case .roller:
            return "keyAssetGroupRoller"
        case .shaft:
            return "keyAssetGroupShaft"
        case .separator:
            return "keyAssetGroupSeparator"
        case .crusher:
            return "keyAssetGroupCrusher"
        case .spindle:
            return "keyAssetGroupSpindle"
        case .press:
            return "keyAssetGroupPress"
        case .device:
            return "keyAssetGroupDevice"
        case .point:
            return "keyAssetGroupPoint"
        case .system:
            return "keyAssetGroupSystem"
        }
    }
    
    var displayName: String {
        switch self {
        case .none:
            return "---"
        case .motor:
            return "Motor"
        case .turbine:
            return "Turbine"
        case .connection:
            return "Connection"
        case .pump:
            return "Pump"
        case .fan:
            return "Fan"
        case .gearbox:
            return "Gearbox"
        case .compressor:
            return "Compressor"
        case .blower:
            return "Blower"
        case .mill:
            return "Mill"
        case .alternator:
            return "Alternator"
        case .generator:
            return "Generator"
        case .mixer:
            return "Mixer"
        case .roller:
            return "Roller"
        case .shaft:
            return "Shaft"
        case .separator:
            return "Separator"
        case .crusher:
            return "Crusher"
        case .spindle:
            return "Spindle"
        case .press:
            return "Press"
        case .device:
            return "Device"
        case .point:
            return "Point"
        case .system:
            return "System"
        }
    }
}

// MARK: - Asset Point Type Enumeration

enum AssetPointType: Int, CaseIterable, Codable {
    case none = -1
    case driveEnd = 0
    case nonDriveEnd = 1
    case firstShaftDriveEnd = 2
    case firstShaftNonDriveEnd = 3
    case firstShaftNonDriveEndInputSide = 4
    case firstShaftInput = 5
    case firstShaftOutput = 6
    case secondShaftDriveEnd = 7
    case secondShaftNonDriveEnd = 8
    case secondShaftNonDriveEndInputSide = 9
    case secondShaftInput = 10
    case secondShaftOutput = 11
    case thirdShaftDriveEnd = 12
    case thirdShaftNonDriveEnd = 13
    case thirdShaftNonDriveEndInputSide = 14
    case fourthShaftDriveEnd = 15
    case fourthShaftNonDriveEnd = 16
    case fourthShaftNonDriveEndInputSide = 17
    case input = 18
    case output = 19
    case mainInput = 20
    case mainOutput = 21
    case pinionDriveEnd = 22
    case pinionNonDriveEnd = 23
    case millDriveEnd = 24
    case millNonDriveEnd = 25
    case pumpDriveEnd = 26
    case pumpNonDriveEnd = 27
    case flywheelDriveEnd = 28
    case flywheelNonDriveEnd = 29
    
    var localizationKey: String {
        switch self {
        case .none:
            return "keyAssetPointTypeNone"
        case .driveEnd:
            return "keyAssetPointTypeDriveEnd"
        case .nonDriveEnd:
            return "keyAssetPointTypeNonDriveEnd"
        case .firstShaftDriveEnd:
            return "keyAssetPointTypeFirstShaftDriveEnd"
        case .firstShaftNonDriveEnd:
            return "keyAssetPointTypeFirstShaftNonDriveEnd"
        case .firstShaftNonDriveEndInputSide:
            return "keyAssetPointTypeFirstShaftNonDriveEndInputSide"
        case .firstShaftInput:
            return "keyAssetPointTypeFirstShaftInput"
        case .firstShaftOutput:
            return "keyAssetPointTypeFirstShaftOutput"
        case .secondShaftDriveEnd:
            return "keyAssetPointTypeSecondShaftDriveEnd"
        case .secondShaftNonDriveEnd:
            return "keyAssetPointTypeSecondShaftNonDriveEnd"
        case .secondShaftNonDriveEndInputSide:
            return "keyAssetPointTypeSecondShaftNonDriveEndInputSide"
        case .secondShaftInput:
            return "keyAssetPointTypeSecondShaftInput"
        case .secondShaftOutput:
            return "keyAssetPointTypeSecondShaftOutput"
        case .thirdShaftDriveEnd:
            return "keyAssetPointTypeThirdShaftDriveEnd"
        case .thirdShaftNonDriveEnd:
            return "keyAssetPointTypeThirdShaftNonDriveEnd"
        case .thirdShaftNonDriveEndInputSide:
            return "keyAssetPointTypeThirdShaftNonDriveEndInputSide"
        case .fourthShaftDriveEnd:
            return "keyAssetPointTypeFourthShaftDriveEnd"
        case .fourthShaftNonDriveEnd:
            return "keyAssetPointTypeFourthShaftNonDriveEnd"
        case .fourthShaftNonDriveEndInputSide:
            return "keyAssetPointTypeFourthShaftNonDriveEndInputSide"
        case .input:
            return "keyAssetPointTypeInput"
        case .output:
            return "keyAssetPointTypeOutput"
        case .mainInput:
            return "keyAssetPointTypeMainInput"
        case .mainOutput:
            return "keyAssetPointTypeMainOutput"
        case .pinionDriveEnd:
            return "keyAssetPointTypePinionDriveEnd"
        case .pinionNonDriveEnd:
            return "keyAssetPointTypePinionNonDriveEnd"
        case .millDriveEnd:
            return "keyAssetPointTypeMillDriveEnd"
        case .millNonDriveEnd:
            return "keyAssetPointTypeMillNonDriveEnd"
        case .pumpDriveEnd:
            return "keyAssetPointTypePumpDriveEnd"
        case .pumpNonDriveEnd:
            return "keyAssetPointTypePumpNonDriveEnd"
        case .flywheelDriveEnd:
            return "keyAssetPointTypeFlywheelDriveEnd"
        case .flywheelNonDriveEnd:
            return "keyAssetPointTypeFlywheelNonDriveEnd"
        }
    }
    
    var displayName: String {
        switch self {
        case .none:
            return "---"
        case .driveEnd:
            return "Drive end"
        case .nonDriveEnd:
            return "Non drive end"
        case .firstShaftDriveEnd:
            return "1st shaft DE"
        case .firstShaftNonDriveEnd:
            return "1st shaft NDE"
        case .firstShaftNonDriveEndInputSide:
            return "1st shaft NDE input side"
        case .firstShaftInput:
            return "1st shaft input"
        case .firstShaftOutput:
            return "1st shaft output"
        case .secondShaftDriveEnd:
            return "2nd shaft DE"
        case .secondShaftNonDriveEnd:
            return "2nd shaft NDE"
        case .secondShaftNonDriveEndInputSide:
            return "2nd shaft NDE input side"
        case .secondShaftInput:
            return "2nd shaft input"
        case .secondShaftOutput:
            return "2nd shaft output"
        case .thirdShaftDriveEnd:
            return "3rd shaft DE"
        case .thirdShaftNonDriveEnd:
            return "3rd shaft NDE"
        case .thirdShaftNonDriveEndInputSide:
            return "3rd shaft NDE input side"
        case .fourthShaftDriveEnd:
            return "4th shaft DE"
        case .fourthShaftNonDriveEnd:
            return "4th shaft NDE"
        case .fourthShaftNonDriveEndInputSide:
            return "4th shaft NDE input side"
        case .input:
            return "Input"
        case .output:
            return "Output"
        case .mainInput:
            return "Main input"
        case .mainOutput:
            return "Main output"
        case .pinionDriveEnd:
            return "Pinion DE"
        case .pinionNonDriveEnd:
            return "Pinion NDE"
        case .millDriveEnd:
            return "Mill DE"
        case .millNonDriveEnd:
            return "Mill NDE"
        case .pumpDriveEnd:
            return "Pump DE"
        case .pumpNonDriveEnd:
            return "Pump NDE"
        case .flywheelDriveEnd:
            return "Flywheel DE"
        case .flywheelNonDriveEnd:
            return "Flywheel NDE"
        }
    }
}

// MARK: - Asset Constants Helper

struct AssetConstants {
    
    // MARK: - Asset Group Helpers
    
    static func getAssetGroup(from rawValue: Int) -> AssetGroup {
        return AssetGroup(rawValue: rawValue) ?? .none
    }
    
    static func getAllAssetGroups() -> [AssetGroup] {
        return AssetGroup.allCases.filter { $0 != .none }
    }
    
    static func getAssetGroupDisplayName(_ group: AssetGroup, localizationManager: LocalizationManager) -> String {
        return NSLocalizedString(group.localizationKey, comment: "").localized(language: localizationManager.currentLanguage)
    }
    
    // MARK: - Asset Point Type Helpers
    
    static func getAssetPointType(from rawValue: Int) -> AssetPointType {
        return AssetPointType(rawValue: rawValue) ?? .none
    }
    
    static func getAllAssetPointTypes() -> [AssetPointType] {
        return AssetPointType.allCases.filter { $0 != .none }
    }
    
    static func getAssetPointTypeDisplayName(_ pointType: AssetPointType, localizationManager: LocalizationManager) -> String {
        return NSLocalizedString(pointType.localizationKey, comment: "").localized(language: localizationManager.currentLanguage)
    }
    
    // MARK: - Asset Group Icons (SF Symbols)
    
    static func getAssetGroupIcon(_ group: AssetGroup) -> String {
        switch group {
        case .motor:
            return "engine.combustion"
        case .turbine:
            return "fan"
        case .connection:
            return "link"
        case .pump:
            return "drop"
        case .fan:
            return "wind"
        case .gearbox:
            return "gearshape"
        case .compressor:
            return "gauge.high"
        case .blower:
            return "wind"
        case .mill:
            return "circle.grid.cross"
        case .alternator, .generator:
            return "bolt"
        case .mixer:
            return "rotate.3d"
        case .roller:
            return "cylinder.split.1x2"
        case .shaft:
            return "line.horizontal.3"
        case .separator:
            return "rectangle.split.2x1"
        case .crusher:
            return "hammer"
        case .spindle:
            return "lineweight"
        case .press:
            return "arrow.down.square"
        case .device:
            return "cpu"
        case .point:
            return "circle"
        case .system:
            return "server.rack"
        case .none:
            return "questionmark"
        }
    }
    
    // MARK: - Asset Point Type Icons (SF Symbols)
    
    static func getAssetPointTypeIcon(_ pointType: AssetPointType) -> String {
        switch pointType {
        case .driveEnd, .firstShaftDriveEnd, .secondShaftDriveEnd, .thirdShaftDriveEnd, .fourthShaftDriveEnd,
             .pinionDriveEnd, .millDriveEnd, .pumpDriveEnd, .flywheelDriveEnd:
            return "arrow.right.circle"
        case .nonDriveEnd, .firstShaftNonDriveEnd, .secondShaftNonDriveEnd, .thirdShaftNonDriveEnd, .fourthShaftNonDriveEnd,
             .pinionNonDriveEnd, .millNonDriveEnd, .pumpNonDriveEnd, .flywheelNonDriveEnd:
            return "arrow.left.circle"
        case .input, .firstShaftInput, .secondShaftInput, .mainInput:
            return "arrow.down.circle"
        case .output, .firstShaftOutput, .secondShaftOutput, .mainOutput:
            return "arrow.up.circle"
        case .firstShaftNonDriveEndInputSide, .secondShaftNonDriveEndInputSide, .thirdShaftNonDriveEndInputSide, .fourthShaftNonDriveEndInputSide:
            return "arrow.turn.up.left"
        case .none:
            return "questionmark.circle"
        }
    }
    
    // MARK: - Date Conversion Helper
    
    static func convertDate(_ dateStr: String, localizationManager: LocalizationManager) -> String {
        // Check if date string is empty or not 14 characters
        if dateStr.isEmpty || dateStr.count != 14 {
            return dateStr
        }
        
        // Extract date components using regex pattern
        let pattern = "([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: dateStr, range: NSRange(dateStr.startIndex..., in: dateStr)),
              match.numberOfRanges == 7 else {
            return dateStr
        }
        
        // Extract year, month, day, hour, minute, second
        let year = Int(String(dateStr[Range(match.range(at: 1), in: dateStr)!])) ?? 0
        let month = Int(String(dateStr[Range(match.range(at: 2), in: dateStr)!])) ?? 0
        let day = Int(String(dateStr[Range(match.range(at: 3), in: dateStr)!])) ?? 0
        let hour = Int(String(dateStr[Range(match.range(at: 4), in: dateStr)!])) ?? 0
        let minute = Int(String(dateStr[Range(match.range(at: 5), in: dateStr)!])) ?? 0
        let second = Int(String(dateStr[Range(match.range(at: 6), in: dateStr)!])) ?? 0
        
        // Check for invalid year
        if year <= 1 {
            return dateStr
        }
        
        // Create date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        guard let date = Calendar.current.date(from: dateComponents) else {
            return dateStr
        }
        
        // Format date according to current language
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localizationManager.currentLanguage == .turkish ? "tr_TR" : "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        return formatter.string(from: date)
    }
}
