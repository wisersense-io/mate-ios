import SwiftUI

// MARK: - Alarm Type Filter Dropdown

struct AlarmTypeFilterDropdown: View {
    @Binding var selectedAlarmType: AlarmType
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Menu {
            ForEach(AlarmConstants.alarmTypeDropdownData, id: \.alarmType.rawValue) { item in
                Button(action: {
                    selectedAlarmType = item.alarmType
                }) {
                    HStack {
                        Text(item.label.localized(language: localizationManager.currentLanguage))
                        if selectedAlarmType == item.alarmType {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedAlarmType.localizationKey.localized(language: localizationManager.currentLanguage))
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(themeManager.currentColors.mainBgColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
            )
        }
    }
}

// MARK: - Alarm Filter Type Dropdown

struct AlarmFilterTypeDropdown: View {
    @Binding var selectedFilterType: AlarmFilterType
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Menu {
            ForEach(AlarmConstants.alarmFilterDropdownData, id: \.filterType.rawValue) { item in
                Button(action: {
                    selectedFilterType = item.filterType
                }) {
                    HStack {
                        Text(item.label.localized(language: localizationManager.currentLanguage))
                        if selectedFilterType == item.filterType {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedFilterType.localizationKey.localized(language: localizationManager.currentLanguage))
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(themeManager.currentColors.mainBgColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
            )
        }
    }
}

// MARK: - System History Date Filter Dropdown

struct SystemHistoryDateFilterDropdown: View {
    @Binding var selectedDateFilter: DashboardDateType
    let availableFilters: [DashboardDateFilter]
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        Menu {
            ForEach(availableFilters, id: \.dateType) { filter in
                Button(action: {
                    selectedDateFilter = filter.dateType
                }) {
                    HStack {
                        Text(getLocalizedFilterTitle(filter.dateType))
                        if selectedDateFilter == filter.dateType {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(getLocalizedFilterTitle(selectedDateFilter))
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(themeManager.currentColors.mainBgColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
            )
        }
    }
    
    private func getLocalizedFilterTitle(_ dateType: DashboardDateType) -> String {
        return DateFilterManager.getLocalizedTitle(for: dateType)
    }
}

// MARK: - Combined Filters Section

struct SystemHistoryFiltersSection: View {
    @Binding var selectedAlarmType: AlarmType
    @Binding var selectedFilterType: AlarmFilterType
    @Binding var selectedDateFilter: DashboardDateType
    let availableFilters: [DashboardDateFilter]
    let isAlarmsTab: Bool
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        HStack(spacing: 12) {
            if isAlarmsTab {
                // First filter - Alarm Type
                AlarmTypeFilterDropdown(selectedAlarmType: $selectedAlarmType)
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
                
                // Second filter - Alarm Filter Type
                AlarmFilterTypeDropdown(selectedFilterType: $selectedFilterType)
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
            } else {
                // For diagnoses tab, show different filters
                // Placeholder for now - can be expanded later
                filterDropdown(title: "Tüm Teşhisler")
                filterDropdown(title: "Tüm Teşhisler")
            }
            
            // Third filter - Date Filter (common for both tabs)
            SystemHistoryDateFilterDropdown(
                selectedDateFilter: $selectedDateFilter,
                availableFilters: availableFilters
            )
            .environmentObject(themeManager)
            .environmentObject(localizationManager)
        }
        .padding(.horizontal, 16)
    }
    
    // Placeholder filter dropdown for diagnoses
    private func filterDropdown(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(themeManager.currentColors.mainTextColor)
            
            Image(systemName: "chevron.down")
                .font(.system(size: 12))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(themeManager.currentColors.mainBgColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
        )
    }
} 