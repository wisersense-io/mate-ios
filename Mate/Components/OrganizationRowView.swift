import SwiftUI

struct OrganizationRowView: View {
    let organization: Organization
    let isSelected: Bool
    let onTap: () -> Void
    let onExpandToggle: (() -> Void)?
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        HStack(spacing: 0) {
            // Indentation for tree structure
            if organization.level > 0 {
                HStack(spacing: 0) {
                    ForEach(0..<organization.level, id: \.self) { _ in
                        Rectangle()
                            .fill(themeManager.currentColors.mainBorderColor.opacity(0.3))
                            .frame(width: 1, height: 40)
                        Spacer()
                            .frame(width: 19)
                    }
                }
            }
            
            // Organization content
            HStack(spacing: 12) {
                // Expand/Collapse button
                if organization.hasChildren {
                    Button(action: {
                        onExpandToggle?()
                    }) {
                        Image(systemName: organization.isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Spacer()
                        .frame(width: 16, height: 16)
                }
                
                // Selection indicator
                Circle()
                    .fill(isSelected ? themeManager.currentColors.mainAccentColor : Color.clear)
                    .stroke(
                        isSelected ? themeManager.currentColors.mainAccentColor : themeManager.currentColors.mainBorderColor,
                        lineWidth: isSelected ? 0 : 1
                    )
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(isSelected ? 1 : 0)
                    )
                
                // Organization name
                VStack(alignment: .leading, spacing: 2) {
                    Text(organization.name)
                        .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(
                            isSelected ? themeManager.currentColors.mainAccentColor : themeManager.currentColors.mainTextColor
                        )
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if organization.hasChildren {
                        Text("\(organization.children.count) \("sub_units".localized(language: localizationManager.currentLanguage))")
                            .font(.caption2)
                            .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Arrow indicator for navigation
                if !organization.hasChildren {
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.4))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(themeManager.currentColors.mainBgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                isSelected ? 
                                themeManager.currentColors.mainAccentColor.opacity(0.1) : 
                                Color.clear
                            )
                    )
            )
            .onTapGesture {
                onTap()
            }
        }
        .background(Color.clear)
    }
}

#Preview {
    VStack(spacing: 8) {
        OrganizationRowView(
            organization: Organization(
                id: "1",
                name: "Fizix",
                parentId: nil,
                children: [
                    Organization(id: "2", name: "Child 1", parentId: "1"),
                    Organization(id: "3", name: "Child 2", parentId: "1")
                ],
                level: 0,
                isExpanded: false
            ),
            isSelected: false,
            onTap: {},
            onExpandToggle: {}
        )
        
        OrganizationRowView(
            organization: Organization(
                id: "2",
                name: "Ako Jant",
                parentId: "1",
                children: [],
                level: 1,
                isExpanded: false
            ),
            isSelected: true,
            onTap: {},
            onExpandToggle: nil
        )
    }
    .environmentObject(ThemeManager.shared)
} 