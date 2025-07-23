import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    ThemeOptionRow(
                        mode: mode,
                        isSelected: themeManager.currentMode == mode,
                        onTap: {
                            themeManager.setThemeMode(mode)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss()
                            }
                        }
                    )
                }
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            .background(themeManager.currentColors.primaryWorkspaceColor)
            .navigationTitle("theme".localized(language: localizationManager.currentLanguage))
            .toolbarBackground(themeManager.currentColors.primaryWorkspaceColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized(language: localizationManager.currentLanguage)) {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                }
            }
            .toolbarBackground(themeManager.currentColors.primaryWorkspaceColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .background(themeManager.currentColors.primaryWorkspaceColor)
    }
}

struct ThemeOptionRow: View {
    let mode: ThemeMode
    let isSelected: Bool
    let onTap: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Theme Icon
                Image(systemName: themeIcon)
                    .font(.title2)
                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(themeDisplayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                    
                    Text(themeDescription)
                        .font(.caption)
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.currentColors.mainAccentColor)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .listRowBackground(themeManager.currentColors.mainBgColor)
    }
    
    private var themeIcon: String {
        switch mode {
        case .system:
            return "gear.badge"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
    
    private var themeDisplayName: String {
        switch mode {
        case .system:
            return "system_theme".localized(language: localizationManager.currentLanguage)
        case .light:
            return "light_theme".localized(language: localizationManager.currentLanguage)
        case .dark:
            return "dark_theme".localized(language: localizationManager.currentLanguage)
        }
    }
    
    private var themeDescription: String {
        switch mode {
        case .system:
            return "theme_system_description".localized(language: localizationManager.currentLanguage)
        case .light:
            return "theme_light_description".localized(language: localizationManager.currentLanguage)
        case .dark:
            return "theme_dark_description".localized(language: localizationManager.currentLanguage)
        }
    }
}

#Preview {
    ThemeSelectionView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(LocalizationManager())
} 