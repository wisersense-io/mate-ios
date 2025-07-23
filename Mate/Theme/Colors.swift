import SwiftUI

// MARK: - Color Definitions
struct AppColors: Equatable {
    let mainBgColor: Color
    let mainTextColor: Color
    let mainBorderColor: Color
    let mainAccentColor: Color
    let mainAccentNotColor: Color
    let primaryWorkspaceColor: Color
    let widgetFillColor: Color
    let nodeFillColor: Color
    let nodeHeaderColor: Color
    let nodeSubHeaderColor: Color
    let nodeBorderColor: Color
    let nodeLinkColor: Color
    let nodeButtonIconColor: Color
    let systemStrokeColor: Color
    let rowAltBg: Color
    let successColor: Color
    let dangerColor: Color
    let svgSymbolColor: Color
    let svgPointEmptyColor: Color
    let svgPointNotEmptyColor: Color
    let signalFillColor: Color
    let signalStrokeColor: Color
}

// MARK: - Light Theme Colors
extension AppColors {
    static let light = AppColors(
        mainBgColor: Color(red: 1.0, green: 1.0, blue: 1.0), // #ffffff
        mainTextColor: Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.87),
        mainBorderColor: Color(red: 224/255, green: 224/255, blue: 224/255),
        mainAccentColor: Color(red: 44/255, green: 180/255, blue: 255/255),
        mainAccentNotColor: Color(red: 1.0, green: 1.0, blue: 1.0),
        primaryWorkspaceColor: Color(red: 244/255, green: 244/255, blue: 244/255),
        widgetFillColor: Color(red: 1.0, green: 1.0, blue: 1.0),
        nodeFillColor: Color(red: 1.0, green: 1.0, blue: 1.0),
        nodeHeaderColor: Color(red: 255/255, green: 87/255, blue: 34/255),
        nodeSubHeaderColor: Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.87),
        nodeBorderColor: Color(red: 122/255, green: 177/255, blue: 215/255),
        nodeLinkColor: Color(red: 122/255, green: 177/255, blue: 215/255),
        nodeButtonIconColor: Color(red: 122/255, green: 177/255, blue: 215/255),
        systemStrokeColor: Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.87),
        rowAltBg: Color(red: 245/255, green: 245/255, blue: 245/255),
        successColor: Color(red: 139/255, green: 195/255, blue: 74/255),
        dangerColor: Color(red: 244/255, green: 67/255, blue: 54/255),
        svgSymbolColor: Color(red: 0.0, green: 0.0, blue: 0.0),
        svgPointEmptyColor: Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.3),
        svgPointNotEmptyColor: Color(red: 33/255, green: 157/255, blue: 226/255),
        signalFillColor: Color(red: 209/255, green: 11/255, blue: 11/255),
        signalStrokeColor: Color(red: 209/255, green: 11/255, blue: 11/255)
    )
}

// MARK: - Dark Theme Colors
extension AppColors {
    static let dark = AppColors(
        mainBgColor: Color(red: 54/255, green: 54/255, blue: 64/255),
        mainTextColor: Color(red: 1.0, green: 1.0, blue: 1.0),
        mainBorderColor: Color(red: 81/255, green: 81/255, blue: 89/255),
        mainAccentColor: Color(red: 44/255, green: 180/255, blue: 255/255),
        mainAccentNotColor: Color(red: 1.0, green: 1.0, blue: 1.0),
        primaryWorkspaceColor: Color(red: 93/255, green: 93/255, blue: 101/255),
        widgetFillColor: Color(red: 0.0, green: 0.0, blue: 0.0),
        nodeFillColor: Color(red: 0.0, green: 0.0, blue: 0.0),
        nodeHeaderColor: Color(red: 255/255, green: 87/255, blue: 34/255),
        nodeSubHeaderColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.8),
        nodeBorderColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.8),
        nodeLinkColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.8),
        nodeButtonIconColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.8),
        systemStrokeColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.87),
        rowAltBg: Color(red: 63/255, green: 63/255, blue: 75/255),
        successColor: Color(red: 139/255, green: 195/255, blue: 74/255),
        dangerColor: Color(red: 244/255, green: 67/255, blue: 54/255),
        svgSymbolColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.8),
        svgPointEmptyColor: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.3),
        svgPointNotEmptyColor: Color(red: 33/255, green: 157/255, blue: 226/255),
        signalFillColor: Color(red: 209/255, green: 11/255, blue: 11/255),
        signalStrokeColor: Color(red: 209/255, green: 11/255, blue: 11/255)
    )
}

// MARK: - Theme Mode Enum
enum ThemeMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentColors: AppColors
    @Published var currentMode: ThemeMode
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selected_theme_mode"
    
    init() {
        // Load saved theme mode or default to system
        let savedMode = userDefaults.string(forKey: themeKey)
        let themeMode = savedMode.flatMap(ThemeMode.init(rawValue:)) ?? .system
        
        // Initialize both properties without using self
        currentMode = themeMode
        
        // Set initial colors based on mode
        switch themeMode {
        case .system:
            currentColors = UITraitCollection.current.userInterfaceStyle == .dark ? AppColors.dark : AppColors.light
        case .light:
            currentColors = AppColors.light
        case .dark:
            currentColors = AppColors.dark
        }
    }
    
    var isDarkMode: Bool {
        switch currentMode {
        case .system:
            return UITraitCollection.current.userInterfaceStyle == .dark
        case .light:
            return false
        case .dark:
            return true
        }
    }
    
    func setThemeMode(_ mode: ThemeMode) {
        currentMode = mode
        userDefaults.set(mode.rawValue, forKey: themeKey)
        currentColors = getColorsForMode(mode)
    }
    
    func updateTheme(isDark: Bool) {
        currentColors = isDark ? AppColors.dark : AppColors.light
    }
    
    private func getColorsForMode(_ mode: ThemeMode) -> AppColors {
        switch mode {
        case .system:
            return UITraitCollection.current.userInterfaceStyle == .dark ? AppColors.dark : AppColors.light
        case .light:
            return AppColors.light
        case .dark:
            return AppColors.dark
        }
    }
    
    // Call this when system theme changes (for system mode)
    func updateSystemTheme() {
        if currentMode == .system {
            currentColors = getColorsForMode(.system)
        }
    }
    
    static let shared = ThemeManager()
}

// MARK: - Color Extensions for Easy Access
extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let mainBg = Color("MainBgColor")
    let mainText = Color("MainTextColor")
    let mainBorder = Color("MainBorderColor")
    let mainAccent = Color("MainAccentColor")
    let mainAccentNot = Color("MainAccentNotColor")
    let primaryWorkspace = Color("PrimaryWorkspaceColor")
    let widgetFill = Color("WidgetFillColor")
    let nodeFill = Color("NodeFillColor")
    let nodeHeader = Color("NodeHeaderColor")
    let nodeSubHeader = Color("NodeSubHeaderColor")
    let nodeBorder = Color("NodeBorderColor")
    let nodeLink = Color("NodeLinkColor")
    let nodeButtonIcon = Color("NodeButtonIconColor")
    let systemStroke = Color("SystemStrokeColor")
    let rowAlt = Color("RowAltBgColor")
    let success = Color("SuccessColor")
    let danger = Color("DangerColor")
    let svgSymbol = Color("SvgSymbolColor")
    let svgPointEmpty = Color("SvgPointEmptyColor")
    let svgPointNotEmpty = Color("SvgPointNotEmptyColor")
    let signalFill = Color("SignalFillColor")
    let signalStroke = Color("SignalStrokeColor")
} 