import SwiftUI

struct LanguageDropdown: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Current Language Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Text(localizationManager.currentLanguage.flag)
                        .font(.system(size: 16))
                    
                    Text(localizationManager.currentLanguage.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(themeManager.currentColors.mainBgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                )
                .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Dropdown Options
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Language.allCases, id: \.self) { language in
                        if language != localizationManager.currentLanguage {
                            Button(action: {
                                localizationManager.setLanguage(language)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isExpanded = false
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Text(language.flag)
                                        .font(.system(size: 16))
                                    
                                    Text(language.displayName)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(themeManager.currentColors.mainTextColor)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(themeManager.currentColors.mainBgColor)
                            .onTapGesture {
                                localizationManager.setLanguage(language)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isExpanded = false
                                }
                            }
                        }
                    }
                }
                .background(themeManager.currentColors.primaryWorkspaceColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                )
                .cornerRadius(6)
                .offset(y: 2)
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .padding(.horizontal)
        .zIndex(isExpanded ? 1000 : 1)
    }
}

#Preview {
    LanguageDropdown()
        .environmentObject(LocalizationManager())
        .environmentObject(ThemeManager())
} 
