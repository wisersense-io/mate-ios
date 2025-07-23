import Foundation

// MARK: - Dashboard Repository Implementation
class DashboardRepository: DashboardRepositoryProtocol {
    
    private let networkDataSource: DashboardNetworkDataSourceProtocol
    
    init(networkDataSource: DashboardNetworkDataSourceProtocol) {
        self.networkDataSource = networkDataSource
    }
    
    func fetchChartDistribution(organizationId: String, dateType: DashboardDateType) async throws -> [DashboardChartData] {
        print("🏛️ DashboardRepository: Fetching chart distribution for organizationId: \(organizationId), dateType: \(dateType)")
        
        do {
            let responseDTO = try await networkDataSource.fetchChartDistribution(
                organizationId: organizationId,
                dateType: dateType.rawValue
            )
            
            let dashboardChartData = responseDTO.toDomainChartData()
            
            print("✅ DashboardRepository: Successfully converted \(dashboardChartData.count) charts")
            return dashboardChartData
            
        } catch {
            print("❌ DashboardRepository: Error fetching chart distribution: \(error)")
            throw error
        }
    }
    
    func fetchSystemAlarmTrend(organizationId: String, dateType: DashboardDateType, resolutionType: DashboardDateResolutionType) async throws -> SystemAlarmTrendData {
        print("🏛️ DashboardRepository: Fetching system alarm trend for organizationId: \(organizationId), dateType: \(dateType), resolutionType: \(resolutionType)")
        
        do {
            let responseDTO = try await networkDataSource.fetchSystemAlarmTrend(
                organizationId: organizationId,
                dateType: dateType.rawValue,
                resolutionType: resolutionType.rawValue
            )
            
            let systemAlarmTrendData = responseDTO.toSystemAlarmTrendData()
            
            print("✅ DashboardRepository: Successfully converted system alarm trend data")
            return systemAlarmTrendData
            
        } catch {
            print("❌ DashboardRepository: Error fetching system alarm trend: \(error)")
            throw error
        }
    }
    
    func fetchSystemHealthScoreTrend(organizationId: String, dateType: DashboardDateType, resolutionType: DashboardDateResolutionType) async throws -> [HealthScoreTrendItem] {
        print("🏛️ DashboardRepository: Fetching system health score trend for organizationId: \(organizationId), dateType: \(dateType), resolutionType: \(resolutionType)")
        
        do {
            let responseDTO = try await networkDataSource.fetchSystemHealthScoreTrend(
                organizationId: organizationId,
                dateType: dateType.rawValue,
                resolutionType: resolutionType.rawValue
            )
            
            // Check for API errors
            if responseDTO.hasError {
                print("❌ System Health Score Trend API Error: \(responseDTO.error ?? "Unknown error")")
                throw APIError.invalidResponse(responseDTO.error ?? "System health score trend fetch failed")
            }
            
            // Check if data exists
            guard let trendData = responseDTO.data else {
                print("❌ System Health Score Trend data is nil")
                throw APIError.invalidResponse("No system health score trend data received")
            }
            
            // Convert DTO to domain entities
            let trendItems = trendData.convertToHealthScoreTrendData()
            
            print("✅ DashboardRepository: Successfully converted system health score trend data")
            return trendItems
            
        } catch {
            print("❌ DashboardRepository: Error fetching system health score trend: \(error)")
            throw error
        }
    }
} 