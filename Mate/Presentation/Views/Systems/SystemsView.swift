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
                // Search Bar
                searchBar
                
                // Systems List with Pull to Refresh
                systemsListWithRefresh
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
            await viewModel.checkAndRefreshIfOrganizationChanged()
            
            await viewModel.loadSystems()
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
                
                TextField("Search systems...", text: $searchText)
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
    
    // MARK: - Systems List with Pull to Refresh
    
    private var systemsListWithRefresh: some View {
        Group {
            if viewModel.isLoading && viewModel.systems.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    Task {
                        await viewModel.checkAndRefreshIfOrganizationChanged()
                        await viewModel.loadSystems()
                    }
                }
                .environmentObject(themeManager)
            } else if viewModel.filteredSystems.isEmpty {
                EmptyStateView()
                    .environmentObject(themeManager)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredSystems, id: \.id) { system in
                            SystemCard(
                                system: system,
                                isAlive: viewModel.isSystemAlive(system.id),
                                isDeviceConnected: viewModel.isDeviceConnected(system.id)
                            )
                                .environmentObject(themeManager)
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
                    // Check if organization changed and refresh if needed
                    await viewModel.checkAndRefreshIfOrganizationChanged()
                    await viewModel.refreshSystems()
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
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text(message)
                .foregroundColor(themeManager.currentColors.mainTextColor)
                .multilineTextAlignment(.center)
            
            Button(action: retry) {
                Text("Retry")
                    .foregroundColor(.white)
                    .padding()
                    .background(themeManager.currentColors.mainAccentColor)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct EmptyStateView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .font(.system(size: 48))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.5))
            
            Text("No systems found")
                .foregroundColor(themeManager.currentColors.mainTextColor)
                .font(.title3)
            
            Text("Try adjusting your filter or refresh the page")
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
