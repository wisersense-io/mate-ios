import SwiftUI

struct DiagnosisWidget: View {
    let diagnoses: [LastDiagnosis]
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
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
                DiagnosisItemView(diagnosis: diagnosis)
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
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    private var levelColor: Color {
        switch diagnosis.level {
        case 1:
            return Color(hex: diagnosis.levelColor) ?? .green
        case 2:
            return Color(hex: diagnosis.levelColor) ?? .yellow
        case 3:
            return Color(hex: diagnosis.levelColor) ?? .orange
        case 4:
            return Color(hex: diagnosis.levelColor) ?? .red
        default:
            return Color(hex: diagnosis.levelColor) ?? .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: diagnosis.iconName)
                .font(.system(size: 20))
                .foregroundColor(levelColor)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Type
                Text("diagnosis_type_\(diagnosis.type)".localized(language: localizationManager.currentLanguage))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                
                // Level
                Text("diagnosis_level_\(diagnosis.level)".localized(language: localizationManager.currentLanguage))
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
            }
            
            Spacer()
            
            // Level indicator
            Circle()
                .fill(levelColor)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
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
