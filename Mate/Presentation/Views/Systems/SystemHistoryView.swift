import SwiftUI

enum HistoryTab: String, CaseIterable {
    case alarms = "alarms"
    case diagnoses = "diagnoses"
    
    var localizedTitle: String {
        switch self {
        case .alarms:
            return "Alarmlar"
        case .diagnoses:
            return "Teşhisler"
        }
    }
}

struct SystemHistoryView: View {
    let system: System
    let isAlive: Bool
    let isDeviceConnected: Bool
    let initialTab: HistoryTab
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: HistoryTab
    @StateObject private var viewModel: SystemHistoryViewModel
    
    init(system: System, isAlive: Bool = false, isDeviceConnected: Bool = false, initialTab: HistoryTab = .alarms) {
        self.system = system
        self.isAlive = isAlive
        self.isDeviceConnected = isDeviceConnected
        self.initialTab = initialTab
        self._selectedTab = State(initialValue: initialTab)
        
        let container = DIContainer.shared
        self._viewModel = StateObject(wrappedValue: SystemHistoryViewModel(
            system: system,
            systemHistoryUseCase: container.systemHistoryUseCaseInstance
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // System Icon Section (same as SystemDetailView)
                systemIconSection
                
                // Tab Section
                tabSection
                
                // Content Section
                contentSection
                
                Spacer()
            }
            .background(themeManager.currentColors.primaryWorkspaceColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        // Custom back button
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                        }
                        
                        // History title with system info
                        VStack(alignment: .leading, spacing: 2) {
                            Text("History of \(system.key)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                            
                            Text(system.description)
                                .font(.caption)
                                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                        }
                    }
                }
            }
            .toolbarBackground(themeManager.currentColors.primaryWorkspaceColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - System Icon Section
    
    private var systemIconSection: some View {
        VStack(spacing: 12) {
            // SVG Icon (same as SystemCard)
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
            
            // Status indicators (same as SystemCard)
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
                        .foregroundColor(system.hasDiagnosis ? themeManager.currentColors.mainAccentColor : themeManager.currentColors.mainTextColor.opacity(0.3))
                    
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
        .frame(maxWidth: .infinity)
        .background(themeManager.currentColors.mainBgColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - Tab Section
    
    private var tabSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(HistoryTab.allCases, id: \.rawValue) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(tab.localizedTitle)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedTab == tab ? 
                                    themeManager.currentColors.mainAccentColor : 
                                    themeManager.currentColors.mainTextColor)
                            
                            // Tab indicator
                            Rectangle()
                                .fill(selectedTab == tab ? 
                                    themeManager.currentColors.mainAccentColor : 
                                    Color.clear)
                                .frame(height: 2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Bottom border
            Rectangle()
                .fill(themeManager.currentColors.mainBorderColor.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        VStack(spacing: 16) {
            // Filter Section with new components
            SystemHistoryFiltersSection(
                selectedAlarmType: $viewModel.selectedAlarmType,
                selectedAlarmFilterType: $viewModel.selectedAlarmFilterType,
                selectedDateFilter: $viewModel.selectedDateFilter,
                availableFilters: viewModel.availableFilters,
                isAlarmsTab: selectedTab == .alarms
            )
            
            // Content based on selected tab
            ScrollView {
                LazyVStack(spacing: 12) {
                    if selectedTab == .alarms {
                        alarmsContent
                    } else {
                        diagnosesContent
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 16)
        .onChange(of: viewModel.selectedAlarmType) { 
            Task {
                await viewModel.updateAlarmType(viewModel.selectedAlarmType)
                await viewModel.loadAlarmHistory()
            }
        }
        .onChange(of: viewModel.selectedAlarmFilterType) {
            Task {
                await viewModel.updateAlarmFilterType(viewModel.selectedAlarmFilterType)
                await viewModel.loadAlarmHistory()
            }
        }
        .onChange(of: viewModel.selectedDateFilter) {
             Task {
                 await viewModel.updateDateFilter(viewModel.selectedDateFilter)
                 if (selectedTab == .alarms) {
                     await viewModel.loadAlarmHistory()
                 } else {
                     await viewModel.loadDiagnosisHistory()
                 }
             }
         }
         .onChange(of: selectedTab) {
             Task {
                 if selectedTab == .alarms {
                     await viewModel.loadAlarmHistory()
                 } else {
                     await viewModel.loadDiagnosisHistory()
                 }
             }
         }
        .task {
            print("📱 SystemHistoryView: Initial task triggered")
            if selectedTab == .alarms {
                await viewModel.loadAlarmHistory()
            } else {
                await viewModel.loadDiagnosisHistory()
            }
        }
    }
    

    
    // MARK: - Content Views
    
    private var alarmsContent: some View {
        VStack {
            if viewModel.isAlarmsLoading {
                ProgressView("Loading alarms...")
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
            } else if let errorMessage = viewModel.alarmsError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                        .multilineTextAlignment(.center)
                    
                    Button("Tekrar Dene") {
                        Task {
                            await viewModel.refreshAlarmHistory()
                        }
                    }
                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
            } else {
                ForEach(viewModel.alarmData) { alarm in
                    AlarmHistoryCard(
                        title: alarm.displayTitle,
                        expert: alarm.expertName,
                        startDate: alarm.formattedStartDate,
                        asset: alarm.assetName,
                        point: alarm.pointName
                    )
                    .environmentObject(themeManager)
                }
                
                if viewModel.alarmData.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 32))
                            .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                        
                        Text("No alarms found for selected filters")
                            .font(.body)
                            .foregroundColor(themeManager.currentColors.mainTextColor)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private var diagnosesContent: some View {
        VStack {
            if viewModel.isDiagnosisLoading {
                ProgressView("Loading diagnoses...")
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
            } else if let errorMessage = viewModel.diagnosisError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                        .multilineTextAlignment(.center)
                    
                    Button("Tekrar Dene") {
                        Task {
                            await viewModel.refreshDiagnosisHistory()
                        }
                    }
                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
            } else {
                ForEach(viewModel.diagnosisData) { diagnosis in
                    DiagnosisHistoryCard(
                        title: diagnosis.displayTitle,
                        expert: diagnosis.expertName,
                        startDate: diagnosis.formattedStartDate,
                        asset: diagnosis.assetName,
                        point: diagnosis.pointName
                    )
                    .environmentObject(themeManager)
                }
                
                if viewModel.diagnosisData.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 32))
                            .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                        
                        Text("No diagnoses found for selected filters")
                            .font(.body)
                            .foregroundColor(themeManager.currentColors.mainTextColor)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - History Cards

struct AlarmHistoryCard: View {
    let title: String
    let expert: String
    let startDate: String
    let asset: String
    let point: String
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and icons
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Stack icon (like in the image)
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                    
                    // Signal/chart icon (red bars like in image)
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Uzman:")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text(expert)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                }
                
                HStack {
                    Text("Başlangıç Tarihi:")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text(startDate)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                }
                
                HStack {
                    Text("Varlık:")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text(asset)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                }
                
                HStack {
                    Text("Nokta:")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text(point)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                }
            }
            
            // Info button (like in image)
            HStack {
                Button(action: {
                    // Info action
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(themeManager.currentColors.mainBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct DiagnosisHistoryCard: View {
    let title: String
    let expert: String
    let startDate: String
    let asset: String
    let point: String
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and icons
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.currentColors.mainAccentColor)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Refresh/sync icon
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                    
                    // Signal/chart icon (red bars like in image)
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
            }
            
            // Details (same as AlarmHistoryCard)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Uzman:")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text(expert)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                }
                
                HStack {
                    Text("Başlangıç Tarihi:")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text(startDate)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                }
                
                HStack {
                    Text("Varlık:")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text(asset)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                }
                
                HStack {
                    Text("Nokta:")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text(point)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentColors.mainTextColor)
                }
            }
            
            // Info button
            HStack {
                Button(action: {
                    // Info action
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(themeManager.currentColors.mainBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
