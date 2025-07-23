import SwiftUI

struct SystemCard: View {
    let system: System
    let isAlive: Bool
    let isDeviceConnected: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    // Default initializer for backward compatibility
    init(system: System, isAlive: Bool = false, isDeviceConnected: Bool = false) {
        self.system = system
        self.isAlive = isAlive
        self.isDeviceConnected = isDeviceConnected
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header - System key and description
            HStack {
                Text(system.key)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                
                Text("-")
                    .font(.headline)
                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.5))
                
                Text(system.description)
                    .font(.headline)
                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
            }
            
            // Body - Centered SVG icon (mainTextColor, no dynamic coloring)
            if let systemInfo = system.parsedInfo {
                SVGView(svgString: systemInfo.icon, size: 120.0)
                    .frame(width: 120, height: 120)
                    .scaledToFit()
                    .environmentObject(themeManager)
            } else {
                // Fallback icon if no SVG
                Image(systemName: "cpu")
                    .font(.system(size: 60))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .frame(width: 120, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.currentColors.primaryWorkspaceColor.opacity(0.3))
                    )
            }
            
            // Footer - Status indicators
            HStack {
                // Left side - Alarm and Diagnosis icons
                HStack(spacing: 8) {
                    // Alarm indicator
                    Image(systemName: "bell")
                        .font(.system(size: 16))
                        .foregroundColor(system.hasAlarm ? .red : themeManager.currentColors.mainTextColor.opacity(0.3))
                    
                    // Diagnosis indicator
                    Image(systemName: "stethoscope")
                        .font(.system(size: 16))
                        .foregroundColor(system.hasDiagnosis ?  themeManager.currentColors.mainAccentColor : themeManager.currentColors.mainTextColor.opacity(0.3))
                    
                    // Alive indicator (running state)
                    Image(systemName: "power")
                        .font(.system(size: 16))
                        .foregroundColor(isAlive ? Color.green : themeManager.currentColors.mainTextColor.opacity(0.3))
                }
                
                Spacer()
                
                // Right side - Connection status
                Image(systemName: isDeviceConnected ? "wifi" : "wifi.slash")
                    .font(.system(size: 16))
                    .foregroundColor(isDeviceConnected ? Color.green : Color.red)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity) // Full width
        .background(themeManager.currentColors.mainBgColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
