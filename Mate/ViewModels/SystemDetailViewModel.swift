import Foundation
import Combine
import SwiftUI

@MainActor
class SystemDetailViewModel: ObservableObject {
    @Published var system: System
    @Published var healthScoreTrendData: [SystemDetailTrendData] = []
    @Published var isHealthScoreTrendLoading = false
    @Published var healthScoreTrendError: String?
    @Published var selectedDateFilter: DashboardDateType = DateFilterManager.defaultSystemDetailFilter
    
    // Available date filters (ortak kullanım)
    let availableFilters: [DashboardDateFilter] = DateFilterManager.availableFilters
    
    private let systemUseCase: SystemUseCase
    private let organizationUseCase: OrganizationUseCaseProtocol
    private var currentOrganizationId: String?
    private var currentTask: Task<Void, Never>?
    
    init(system: System, systemUseCase: SystemUseCase, organizationUseCase: OrganizationUseCaseProtocol) {
        self.system = system
        self.systemUseCase = systemUseCase
        self.organizationUseCase = organizationUseCase
    }
    
    // MARK: - Public Methods
    
    func loadHealthScoreTrend() async {
        // Cancel any existing request
        currentTask?.cancel()
        
        guard !isHealthScoreTrendLoading else { return }
        
        isHealthScoreTrendLoading = true
        healthScoreTrendError = nil
        
        // Create a new task for this request
        currentTask = Task { @MainActor in
            do {
                // Check if task was cancelled
                try Task.checkCancellation()
                
                // 1 aylık'tan fazla veriler için haftalık yap
                let apiDateType = DateFilterManager.getAPIDateType(for: selectedDateFilter)
                let isWeekly = DateFilterManager.shouldUseWeeklyResolution(for: selectedDateFilter)
                
                print("📊 SystemDetailViewModel: Loading trend for filter: \(selectedDateFilter) -> API dateType: \(apiDateType) (weekly: \(isWeekly))")
                
                let trendData = try await systemUseCase.getSystemHealthScoreTrend(
                    systemId: system.id,
                    dateType: apiDateType
                )
                
                // Check if task was cancelled after the network call
                try Task.checkCancellation()
                
                healthScoreTrendData = trendData
                print("✅ SystemDetailViewModel: Loaded \(trendData.count) health score trend data points")
                
            } catch is CancellationError {
                // Don't show error for cancelled requests
                print("🚫 SystemDetailViewModel: Request was cancelled")
                healthScoreTrendData = []
            } catch {
                // Handle network errors properly
                let errorMessage = getErrorMessage(from: error)
                healthScoreTrendError = errorMessage
                healthScoreTrendData = []
                print("❌ SystemDetailViewModel: Failed to load health score trend - \(error.localizedDescription)")
            }
            
            isHealthScoreTrendLoading = false
        }
        
        await currentTask?.value
    }
    
    func updateDateFilter(_ dateType: DashboardDateType) async {
        selectedDateFilter = dateType
        await loadHealthScoreTrend()
    }
    
    func refreshHealthScoreTrend() async {
        // Cancel any existing request before starting a new one
        currentTask?.cancel()
        await loadHealthScoreTrend()
    }
    
    // MARK: - Organization Management
    
    private func getOrganizationId() -> String? {
        // organizationUseCase.getSelectedOrganization() is synchronous
        return organizationUseCase.getSelectedOrganization()
    }
    
    func checkAndRefreshIfOrganizationChanged() async -> Bool {
        if let newOrganizationId = getOrganizationId(),
           newOrganizationId != currentOrganizationId {
            currentOrganizationId = newOrganizationId
            await loadHealthScoreTrend()
            return true // Data was refreshed
        }
        return false // No refresh needed
    }
    
    // MARK: - Helper Methods
    
    func getLocalizedFilterTitle(_ dateType: DashboardDateType) -> String {
        return DateFilterManager.getLocalizedTitle(for: dateType)
    }
    
    // Get formatted health score (toFixed(2))
    var formattedHealthScore: String {
        return String(format: "%.2f", system.healthScore)
    }
    
    // Get health score for gauge (0-100 range)
    var gaugeHealthScore: Double {
        return max(0, min(100, system.healthScore))
    }
    
    // Convert SystemDetailTrendData to HealthScoreTrendItem for SimpleLineChart
    var simpleLineChartData: [HealthScoreTrendItem] {
        return healthScoreTrendData.toHealthScoreTrendItems()
    }
    
    // MARK: - Error Handling
    
    private func getErrorMessage(from error: Error) -> String {
        if let authError = error as? AuthError {
            switch authError {
            case .networkError:
                return "Network connection error. Please check your internet connection."
            case .serverError(let message, let code):
                if code == 401 {
                    return "Authentication failed. Please login again."
                } else if code >= 500 {
                    return "Server error. Please try again later."
                } else {
                    return message.isEmpty ? "Unknown server error" : message
                }
            default:
                return authError.localizedDescription
            }
        } else {
            // Handle NSURLError specifically
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorTimedOut:
                    return "Request timed out. Please try again."
                case NSURLErrorNotConnectedToInternet:
                    return "No internet connection. Please check your network."
                case NSURLErrorCannotConnectToHost:
                    return "Cannot connect to server. Please try again later."
                case NSURLErrorCancelled:
                    return "Request was cancelled"
                default:
                    return "Network error. Please try again."
                }
            }
            return error.localizedDescription
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        currentTask?.cancel()
    }
} 