import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var dashboardItems: [HomeDashboardItem] = []
    @Published var healthScore: Double = 7.8  // Default value, will be updated from API
    @Published var healthScoreTrendData: [HealthScoreTrendItem] = []  // Chart data from API
    @Published var isLoading: Bool = false
    @Published var isHealthScoreLoading: Bool = false
    @Published var isTrendLoading: Bool = false
    @Published var errorMessage: String?
    @Published var healthScoreError: String?
    @Published var trendError: String?
    
    private let homeUseCase: HomeUseCaseProtocol
    private let organizationUseCase: OrganizationUseCaseProtocol
    private var currentTask: Task<Void, Never>?
    private var healthScoreTask: Task<Void, Never>?
    private var trendTask: Task<Void, Never>?
    private var lastUsedOrganizationId: String?
    
    init(homeUseCase: HomeUseCaseProtocol = DIContainer.shared.makeHomeUseCase(),
         organizationUseCase: OrganizationUseCaseProtocol = DIContainer.shared.makeOrganizationUseCase()) {
        self.homeUseCase = homeUseCase
        self.organizationUseCase = organizationUseCase
    }
    
    deinit {
        currentTask?.cancel()
        healthScoreTask?.cancel()
        trendTask?.cancel()
    }
    
    func loadDashboardData() async {
        // Cancel any existing task
        currentTask?.cancel()
        
        // Create new task
        currentTask = Task {
            await performDataLoad()
        }
        
        await currentTask?.value
    }
    
    func loadHealthScore() async {
        // Cancel any existing health score task
        healthScoreTask?.cancel()
        
        // Create new task
        healthScoreTask = Task {
            await performHealthScoreLoad()
        }
        
        await healthScoreTask?.value
    }
    
    func loadHealthScoreTrend() async {
        // Cancel any existing trend task
        trendTask?.cancel()
        
        // Create new task
        trendTask = Task {
            await performTrendLoad()
        }
        
        await trendTask?.value
    }
    
    private func performHealthScoreLoad() async {
        isHealthScoreLoading = true
        healthScoreError = nil
        
        // Check if task is cancelled
        if Task.isCancelled {
            isHealthScoreLoading = false
            return
        }
        
        do {
            // Check if task is cancelled before API call
            if Task.isCancelled {
                isHealthScoreLoading = false
                return
            }
            
            let healthScoreResult = try await homeUseCase.getHealthScore()
            
            // Check if task is cancelled after API call
            if Task.isCancelled {
                isHealthScoreLoading = false
                return
            }
            
            // Update health score
            healthScore = healthScoreResult.score
            
        } catch {
            // Don't show error if task was cancelled
            if Task.isCancelled {
                isHealthScoreLoading = false
                return
            }
            
            healthScoreError = error.localizedDescription
            
            // Additional error details
            if let apiError = error as? APIError {
                print("🔍 Health Score API Error details: \(apiError)")
            }
        }
        
        isHealthScoreLoading = false
        healthScoreTask = nil
    }
    
    private func performDataLoad() async {
        isLoading = true
        errorMessage = nil
        
        // Check if task is cancelled
        if Task.isCancelled {
            isLoading = false
            return
        }
        
        do {
            // Check if task is cancelled before API call
            if Task.isCancelled {
                isLoading = false
                return
            }
            
            let dashboardInfo = try await homeUseCase.getDashboardInfo()
            
            // Check if task is cancelled after API call
            if Task.isCancelled {
                isLoading = false
                return
            }
            
            // Get current language for localized titles
            let currentLanguage = UserDefaults.standard.string(forKey: "app_language") ?? "en"
            
            // Convert to dashboard items
            dashboardItems = dashboardInfo.toDashboardItems(language: currentLanguage)
            
        } catch {
            // Don't show error if task was cancelled
            if Task.isCancelled {
                isLoading = false
                return
            }
            
            errorMessage = error.localizedDescription
            print("❌ Dashboard loading error: \(error)")
            
            // Additional error details
            if let apiError = error as? APIError {
                print("🔍 API Error details: \(apiError)")
            }
        }
        
        isLoading = false
        currentTask = nil
    }
    
    private func performTrendLoad() async {
        isTrendLoading = true
        trendError = nil
        
        // Check if task is cancelled
        if Task.isCancelled {
            isTrendLoading = false
            return
        }
        
        do {
            // Check if task is cancelled before API call
            if Task.isCancelled {
                isTrendLoading = false
                return
            }
            
            let trendResult = try await homeUseCase.getHealthScoreTrend()
            
            // Check if task is cancelled after API call
            if Task.isCancelled {
                isTrendLoading = false
                return
            }
            
            // Update trend data
            healthScoreTrendData = trendResult.items
            
        } catch {
            // Don't show error if task was cancelled
            if Task.isCancelled {
                isTrendLoading = false
                return
            }
            
            trendError = error.localizedDescription
            print("❌ Health Score Trend loading error: \(error)")
            
            // Additional error details
            if let apiError = error as? APIError {
                print("🔍 Trend API Error details: \(apiError)")
            }
        }
        
        isTrendLoading = false
        trendTask = nil
    }
    
    // MARK: - Organization Management
    
    func checkAndRefreshIfOrganizationChanged() async -> Bool {
        let currentOrganizationId = organizationUseCase.getActiveOrganization()
        
        if currentOrganizationId != lastUsedOrganizationId {
            lastUsedOrganizationId = currentOrganizationId
            
            // Refresh all data when organization changes
            await refreshAllData()
            return true // Data was refreshed
        }
        return false // No refresh needed
    }
    
    private func refreshAllData() async {
        // Load all data sequentially to avoid race conditions
        await loadDashboardData()
        await loadHealthScore()
        await loadHealthScoreTrend()
    }
} 
