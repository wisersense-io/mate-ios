import SwiftUI

struct SystemsView: View {
    @StateObject private var viewModel: SystemsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var searchText = ""
    @State private var isRefreshing = false
    
    init() {
        let container = DIContainer.shared
        self._viewModel = StateObject(wrappedValue: SystemsViewModel(
            systemUseCase: container.systemUseCaseInstance,
            organizationUseCase: container.organizationUseCaseInstance
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar - Always visible
                searchBar
                
                // Content Area - Systems List or Empty State
                contentArea
            }
            .background(themeManager.currentColors.primaryWorkspaceColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Mate Logo
                    Image(themeManager.isDarkMode ? "dark_mate_logo" : "light_mate_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Filter Menu
                    Menu {
                        ForEach(SystemFilterType.allCases, id: \.rawValue) { filter in
                            Button(action: {
                                viewModel.filterChanged(filter)
                            }) {
                                HStack {
                                    Text(filter.localizedTitle)
                                    if viewModel.selectedFilter == filter {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedFilter.localizedTitle)
                                .font(.caption)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(themeManager.currentColors.mainBgColor)
                                .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                        )
                    }
                }
            }
            .toolbarBackground(themeManager.currentColors.primaryWorkspaceColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .task {
            print("📱 SystemsView: Initial task triggered")
            
            // Check if organization changed and refresh if needed
            let organizationChanged = await viewModel.checkAndRefreshIfOrganizationChanged()
            
            if !organizationChanged {
                await viewModel.loadSystems()
            }
            // Start SignalR connection after loading systems
            await viewModel.startSignalRConnection()
        }
        .onDisappear {
            Task {
                await viewModel.stopSignalRConnection()
            }
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.searchSystems(query: newValue)
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                
                TextField(NSLocalizedString("search_systems_placeholder".localized(language: localizationManager.currentLanguage), comment: "Search systems placeholder"), text: $searchText)
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .accentColor(themeManager.currentColors.mainAccentColor)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(themeManager.currentColors.mainBgColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(themeManager.currentColors.primaryWorkspaceColor)
    }
    
    // MARK: - Content Area
    
    private var contentArea: some View {
        Group {
            if viewModel.isLoading && viewModel.systems.isEmpty {
                // Loading state
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                // Error state
                VStack {
                    Spacer()
                    ErrorView(message: errorMessage) {
                        Task {
                            let organizationChanged = await viewModel.checkAndRefreshIfOrganizationChanged()
                            if !organizationChanged {
                                await viewModel.loadSystems()
                            }
                        }
                    }
                    .environmentObject(themeManager)
                    .environmentObject(localizationManager)
                    Spacer()
                }
            } else if viewModel.filteredSystems.isEmpty {
                // Empty state - only in content area
                VStack {
                    Spacer()
                    EmptyStateView()
                        .environmentObject(themeManager)
                        .environmentObject(localizationManager)
                    Spacer()
                }
            } else {
                // Systems list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredSystems, id: \.id) { system in
                            SystemCard(
                                system: system,
                                isAlive: viewModel.isSystemAlive(system.id),
                                isDeviceConnected: viewModel.isDeviceConnected(system.id)
                            )
                                .environmentObject(themeManager)
                                .environmentObject(localizationManager)
                                .onAppear {
                                    // Load more when reaching near the end
                                    if system.id == viewModel.filteredSystems.last?.id {
                                        Task {
                                            await viewModel.loadMoreSystems()
                                        }
                                    }
                                }
                        }
                        
                        // Load more indicator
                        if viewModel.isLoadingMore {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding()
                }
                .refreshable {
                    isRefreshing = true
                    
                    // Add a small delay to ensure UI is ready
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    
                    // Check if organization changed and refresh if needed
                    let organizationChanged = await viewModel.checkAndRefreshIfOrganizationChanged()
                    if !organizationChanged {
                        await viewModel.refreshSystems()
                    }
                    isRefreshing = false
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text(message)
                .foregroundColor(themeManager.currentColors.mainTextColor)
                .multilineTextAlignment(.center)
            
            Button(action: retry) {
                Text("retry".localized(language: localizationManager.currentLanguage))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(themeManager.currentColors.mainAccentColor)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct EmptyStateView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(NSLocalizedString("no_systems_found_search".localized(language: localizationManager.currentLanguage), comment: "No systems found message"))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(NSLocalizedString("no_systems_found_search_description".localized(language: localizationManager.currentLanguage), comment: "No systems found description"))
                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
    }
}
