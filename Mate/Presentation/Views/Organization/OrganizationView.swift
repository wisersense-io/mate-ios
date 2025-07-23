import SwiftUI

struct OrganizationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var viewModel: OrganizationSelectorViewModel
    @State private var scrollOffset: CGFloat = 0
    
    init() {
        let organizationUseCase = DIContainer.shared.makeOrganizationUseCase()
        self._viewModel = StateObject(wrappedValue: OrganizationSelectorViewModel(organizationUseCase: organizationUseCase))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentColors.primaryWorkspaceColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBarSection
                    
                    // Content
                    if viewModel.isLoading {
                        loadingSection
                    } else if let errorMessage = viewModel.errorMessage {
                        errorSection(errorMessage)
                    } else {
                        organizationListSection
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // Mate Logo
                    Image(themeManager.isDarkMode ? "dark_mate_logo" : "light_mate_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                }
                
                ToolbarItem(placement: .principal) {
                    // Title or Selected Organization
                    if scrollOffset > 50 && viewModel.hasSelectedOrganization {
                        Text(viewModel.selectedOrganization?.name ?? "")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.currentColors.mainTextColor)
                            .lineLimit(1)
                    } else {
                        Text("organization_selector".localized(language: localizationManager.currentLanguage))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.currentColors.mainTextColor)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    // Selected Organization Badge
                    if viewModel.hasSelectedOrganization {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(themeManager.currentColors.mainAccentColor)
                                .frame(width: 8, height: 8)
                            Text(viewModel.selectedOrganization?.name ?? "")
                                .font(.caption)
                                .foregroundColor(themeManager.currentColors.mainTextColor)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.currentColors.mainBgColor)
                                .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                        )
                    }
                }
            }
            .toolbarBackground(themeManager.currentColors.primaryWorkspaceColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task {
                await viewModel.loadOrganizations()
            }
            .onChange(of: viewModel.searchText) { _, newValue in
                if newValue.count >= 2 {
                    viewModel.performDebouncedSearch()
                } else if newValue.isEmpty {
                    viewModel.clearSearch()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var searchBarSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                    
                    TextField(
                        "organization_search_placeholder".localized(language: localizationManager.currentLanguage),
                        text: $viewModel.searchText
                    )
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.currentColors.mainTextColor)
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.clearSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(themeManager.currentColors.mainBgColor)
                        .stroke(themeManager.currentColors.mainBorderColor, lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
                .background(themeManager.currentColors.mainBorderColor)
        }
        .background(themeManager.currentColors.primaryWorkspaceColor)
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("loading_organizations".localized(language: localizationManager.currentLanguage))
                .font(.subheadline)
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorSection(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.6))
            
            Text("error_loading_organizations".localized(language: localizationManager.currentLanguage))
                .font(.headline)
                .foregroundColor(themeManager.currentColors.mainTextColor)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Tekrar Dene") {
                Task {
                    await viewModel.loadOrganizations()
                }
            }
            .foregroundColor(themeManager.currentColors.mainAccentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var organizationListSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.displayOrganizations.isEmpty {
                        emptyStateSection
                    } else {
                        ForEach(viewModel.displayOrganizations) { organization in
                            OrganizationRowView(
                                organization: organization,
                                isSelected: viewModel.selectedOrganization?.id == organization.id,
                                onTap: {
                                    viewModel.selectOrganization(organization)
                                },
                                onExpandToggle: organization.hasChildren ? {
                                    viewModel.toggleExpansion(for: organization.id)
                                } : nil
                            )
                            .id(organization.id)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
            }
        }
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 48))
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.4))
            
            Text("no_organizations_found".localized(language: localizationManager.currentLanguage))
                .font(.headline)
                .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.7))
            
            if !viewModel.searchText.isEmpty {
                Text("Arama kriterini değiştirmeyi deneyin")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentColors.mainTextColor.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    OrganizationView()
        .environmentObject(ThemeManager.shared)
} 
