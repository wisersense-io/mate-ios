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
        print("🔄 HomeViewModel: loadDashboardData called")
        
        // Cancel any existing task
        currentTask?.cancel()
        
        // Create new task
        currentTask = Task {
            await performDataLoad()
        }
        
        await currentTask?.value
    }
    
    func loadHealthScore() async {
        print("🔄 HomeViewModel: loadHealthScore called")
        
        // Cancel any existing health score task
        healthScoreTask?.cancel()
        
        // Create new task
        healthScoreTask = Task {
            await performHealthScoreLoad()
        }
        
        await healthScoreTask?.value
    }
    
    func loadHealthScoreTrend() async {
        print("🔄 HomeViewModel: loadHealthScoreTrend called")
        
        // Cancel any existing trend task
        trendTask?.cancel()
        
        // Create new task
        trendTask = Task {
            await performTrendLoad()
        }
        
        await trendTask?.value
    }
    
    private func performHealthScoreLoad() async {
        print("📊 Starting performHealthScoreLoad...")
        isHealthScoreLoading = true
        healthScoreError = nil
        
        // Check if task is cancelled
        if Task.isCancelled {
            print("⏹️ Health Score task was cancelled before starting")
            isHealthScoreLoading = false
            return
        }
        
        do {
            // Check if task is cancelled before API call
            if Task.isCancelled {
                print("⏹️ Health Score task was cancelled before API call")
                isHealthScoreLoading = false
                return
            }
            
            let healthScoreResult = try await homeUseCase.getHealthScore()
            
            // Check if task is cancelled after API call
            if Task.isCancelled {
                print("⏹️ Health Score task was cancelled after API call")
                isHealthScoreLoading = false
                return
            }
            
            // Update health score
            healthScore = healthScoreResult.score
            print("✅ Health Score loaded successfully: \(healthScore)")
            
        } catch {
            // Don't show error if task was cancelled
            if Task.isCancelled {
                print("⏹️ Health Score task was cancelled, ignoring error")
                isHealthScoreLoading = false
                return
            }
            
            healthScoreError = error.localizedDescription
            print("❌ Health Score loading error: \(error)")
            
            // Additional error details
            if let apiError = error as? APIError {
                print("🔍 Health Score API Error details: \(apiError)")
            }
        }
        
        isHealthScoreLoading = false
        healthScoreTask = nil
    }
    
    private func performDataLoad() async {
        print("📥 Starting performDataLoad...")
        isLoading = true
        errorMessage = nil
        
        // Check if task is cancelled
        if Task.isCancelled {
            print("⏹️ Task was cancelled before starting")
            isLoading = false
            return
        }
        
        // Check session state
        print("👤 Current User: \(UserSessionManager.shared.currentUser?.name ?? "None")")
        print("🏢 Current Org ID: \(UserSessionManager.shared.getCurrentOrganizationId() ?? "None")")
        print("🔐 Is Logged In: \(UserSessionManager.shared.isLoggedIn)")
        
        do {
            // Check if task is cancelled before API call
            if Task.isCancelled {
                print("⏹️ Task was cancelled before API call")
                isLoading = false
                return
            }
            
            let dashboardInfo = try await homeUseCase.getDashboardInfo()
            
            // Check if task is cancelled after API call
            if Task.isCancelled {
                print("⏹️ Task was cancelled after API call")
                isLoading = false
                return
            }
            
            // Get current language for localized titles
            let currentLanguage = UserDefaults.standard.string(forKey: "app_language") ?? "en"
            
            // Convert to dashboard items
            dashboardItems = dashboardInfo.toDashboardItems(language: currentLanguage)
            print("✅ Dashboard data loaded successfully with \(dashboardItems.count) items")
            
        } catch {
            // Don't show error if task was cancelled
            if Task.isCancelled {
                print("⏹️ Task was cancelled, ignoring error")
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
        print("📈 Starting performTrendLoad...")
        isTrendLoading = true
        trendError = nil
        
        // Check if task is cancelled
        if Task.isCancelled {
            print("⏹️ Trend task was cancelled before starting")
            isTrendLoading = false
            return
        }
        
        do {
            // Check if task is cancelled before API call
            if Task.isCancelled {
                print("⏹️ Trend task was cancelled before API call")
                isTrendLoading = false
                return
            }
            
            let trendResult = try await homeUseCase.getHealthScoreTrend()
            
            // Check if task is cancelled after API call
            if Task.isCancelled {
                print("⏹️ Trend task was cancelled after API call")
                isTrendLoading = false
                return
            }
            
            // Update trend data
            healthScoreTrendData = trendResult.items
            print("✅ Health Score Trend loaded successfully with \(healthScoreTrendData.count) data points")
            
        } catch {
            // Don't show error if task was cancelled
            if Task.isCancelled {
                print("⏹️ Trend task was cancelled, ignoring error")
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
    
    func checkAndRefreshIfOrganizationChanged() async {
        let currentOrganizationId = organizationUseCase.getActiveOrganization()
        
        if currentOrganizationId != lastUsedOrganizationId {
            print("🔄 HomeViewModel: Organization changed from \(lastUsedOrganizationId ?? "nil") to \(currentOrganizationId ?? "nil")")
            lastUsedOrganizationId = currentOrganizationId
            
            // Refresh all data when organization changes
            await refreshAllData()
        }
    }
    
    private func refreshAllData() async {
        print("🔄 HomeViewModel: Refreshing all data due to organization change")
        
        // Load all data in parallel
        async let _ = loadDashboardData()
        async let _ = loadHealthScore()
        async let _ = loadHealthScoreTrend()
    }
} 
