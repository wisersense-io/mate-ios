import SwiftUI

struct SystemFilterDropdown: View {
    @Binding var selectedFilter: SystemFilterType
    let onFilterChanged: (SystemFilterType) -> Void
    @State private var isExpanded = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack {
            // Dropdown Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                    
                    Text(selectedFilter.localizedTitle)
                        .font(.caption)
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(themeManager.currentColors.mainBgColor)
                .cornerRadius(8)
            }
            
            // Dropdown Menu
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(SystemFilterType.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            onFilterChanged(filter)
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                Text(filter.localizedTitle)
                                    .font(.caption)
                                    .foregroundColor(themeManager.currentColors.mainTextColor)
                                
                                Spacer()
                                
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(themeManager.currentColors.mainAccentColor)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ? 
                                themeManager.currentColors.mainAccentColor.opacity(0.1) :
                                Color.clear
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if filter != SystemFilterType.allCases.last {
                            Divider()
                                .background(themeManager.currentColors.mainTextColor.opacity(0.2))
                        }
                    }
                }
                .background(themeManager.currentColors.mainBgColor)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .zIndex(1000)
    }
}

#Preview {
    SystemFilterDropdown(
        selectedFilter: .constant(.all),
        onFilterChanged: { filter in
            print("Filter changed to: \(filter)")
        }
    )
    .padding()
} 