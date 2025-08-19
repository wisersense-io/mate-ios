import SwiftUI

// Import necessary models and services
// Note: LastDiagnosis is defined in DiagnosisDTOs.swift
// Note: FailureDataService is defined in Services/FailureDataService.swift
// Note: ThemeManager and LocalizationManager are defined in their respective files

struct DiagnosisWidget: View {
    let diagnoses: [LastDiagnosis]
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var failureDataService = FailureDataService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("diagnosis_title".localized(language: localizationManager.currentLanguage))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                
                Spacer()
                
                // Diagnoses count
                if !diagnoses.isEmpty {
                    Text("\(diagnoses.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(minWidth: 20, minHeight: 20)
                        .background(Circle().fill(themeManager.currentColors.mainAccentColor))
                }
            }
            
            // Content
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if diagnoses.isEmpty {
                emptyStateView
            } else {
                diagnosisContentView
            }
        }
        .padding(16)
        .background(themeManager.currentColors.mainBgColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            
            Text("loading_diagnosis".localized(language: localizationManager.currentLanguage))
                .font(.system(size: 14))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
            
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button("retry".localized(language: localizationManager.currentLanguage)) {
                onRetry()
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(themeManager.currentColors.mainAccentColor)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "stethoscope")
                .font(.system(size: 24))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
            
            Text("no_diagnosis_found".localized(language: localizationManager.currentLanguage))
                .font(.system(size: 12))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Diagnosis Content View
    
    private var diagnosisContentView: some View {
        VStack(spacing: 12) {
            ForEach(Array(diagnoses.enumerated()), id: \.offset) { index, diagnosis in
                DiagnosisItemView(diagnosis: diagnosis, failureDataService: failureDataService)
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
                
                // Add divider between items (except last item)
                if index < diagnoses.count - 1 {
                    Divider()
                        .background(themeManager.currentColors.mainBorderColor.opacity(0.3))
                }
            }
        }
    }
}

// MARK: - Diagnosis Item View

struct DiagnosisItemView: View {
    let diagnosis: LastDiagnosis
    let failureDataService: FailureDataService
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    // MARK: - Computed Properties
    
    private var failureItem: FailureItem? {
        return failureDataService.getFailureByType(diagnosis.type)
    }
    
    private var diagnosisLabel: String {
        if let failureItem = failureItem {
            let language = localizationManager.currentLanguage == .turkish ? "tr_TR" : "en_US"
            return failureItem.getCaption(language: language)
        } else {
            // Fallback to unknown diagnosis message
            return "wiserSenseLocalization.key_unkown_diagnosis_type".localized(language: localizationManager.currentLanguage) + " \(diagnosis.type)"
        }
    }
    
    private var diagnosisLevel: DiagnosisLevel {
        return DiagnosisLevel(rawValue: diagnosis.level) ?? .level0
    }
    
    private var levelColor: Color {
        switch diagnosisLevel {
        case .level0: return .red
        case .level1: return .red
        case .level2: return .red
        }
    }
    
    private var diagnosisIconSVG: String? {
        return failureDataService.getIconSVG(for: diagnosis.type)
    }
    
    private var hasVisibleIcon: Bool {
        return failureDataService.hasVisibleIcon(for: diagnosis.type)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Diagnosis Label
            VStack(alignment: .leading, spacing: 4) {
                Text(diagnosisLabel)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Diagnosis SVG Icon (from FailureLists.json)
            if hasVisibleIcon, let svgString = diagnosisIconSVG {
                SVGView(svgString: svgString, size: 24.0)
                    .frame(width: 24, height: 24)
                    .environmentObject(themeManager)
            } else {
                // Fallback to SF Symbol based on level
                Image(systemName: diagnosisLevel.sfSymbol)
                    .font(.system(size: 20))
                    .foregroundColor(levelColor)
                    .frame(width: 24, height: 24)
            }
            
            // Level indicator bars (mimicking React Native SVG bars)
            diagnosisLevelBars
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Level Bars (mimicking React Native SVG)
    
    private var diagnosisLevelBars: some View {
        HStack(spacing: 3) {
            // Bar 1 (level >= 0)
            Rectangle()
                .fill(diagnosis.level >= 0 ? levelColor : Color.clear)
                .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                .frame(width: 6, height: 8)
            
            // Bar 2 (level >= 1) 
            Rectangle()
                .fill(diagnosis.level >= 1 ? levelColor : Color.clear)
                .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                .frame(width: 6, height: 16)
            
            // Bar 3 (level == 2)
            Rectangle()
                .fill(diagnosis.level == 2 ? levelColor : Color.clear)
                .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                .frame(width: 6, height: 24)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        // With data
        DiagnosisWidget(
            diagnoses: [
                LastDiagnosis(level: 3, type: 1),
                LastDiagnosis(level: 2, type: 2)
            ],
            isLoading: false,
            errorMessage: nil,
            onRetry: {}
        )
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager())
        
        // Loading state
        DiagnosisWidget(
            diagnoses: [],
            isLoading: true,
            errorMessage: nil,
            onRetry: {}
        )
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager())
        
        // Error state
        DiagnosisWidget(
            diagnoses: [],
            isLoading: false,
            errorMessage: "Network connection error",
            onRetry: {}
        )
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager())
        
        // Empty state
        DiagnosisWidget(
            diagnoses: [],
            isLoading: false,
            errorMessage: nil,
            onRetry: {}
        )
        .environmentObject(ThemeManager())
        .environmentObject(LocalizationManager())
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
