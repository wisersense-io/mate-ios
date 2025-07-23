import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Language.allCases, id: \.self) { language in
                    LanguageOptionRow(
                        language: language,
                        isSelected: localizationManager.currentLanguage == language,
                        onTap: {
                            localizationManager.setLanguage(language)
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
            .navigationTitle("language".localized(language: localizationManager.currentLanguage))
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

struct LanguageOptionRow: View {
    let language: Language
    let isSelected: Bool
    let onTap: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Language Flag
                Text(language.flag)
                    .font(.title)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                    
                    Text(languageNativeName)
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
    
    private var languageNativeName: String {
        switch language {
        case .turkish:
            return "Türkçe"
        case .english:
            return "English"
        }
    }
}

#Preview {
    LanguageSelectionView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(LocalizationManager())
} 