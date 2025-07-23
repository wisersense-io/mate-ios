import Foundation

// MARK: - Dashboard Network Data Source Protocol
protocol DashboardNetworkDataSourceProtocol {
    func fetchChartDistribution(organizationId: String, dateType: Int) async throws -> DashboardChartDistributionResponseDTO
    func fetchSystemAlarmTrend(organizationId: String, dateType: Int, resolutionType: Int) async throws -> SystemAlarmTrendResponseDTO
    func fetchSystemHealthScoreTrend(organizationId: String, dateType: Int, resolutionType: Int) async throws -> HealthScoreTrendResponseDTO
}

// MARK: - Dashboard Network Data Source Implementation
class DashboardNetworkDataSource: DashboardNetworkDataSourceProtocol {
    
    private let urlSession: URLSession
    private let tokenStorage: TokenStorageServiceProtocol
    
    // Base URL for API
    private let baseURL = "https://mateapi.fizix.ai/api/v1"
    
    init(
        urlSession: URLSession = URLSession.shared,
        tokenStorage: TokenStorageServiceProtocol
    ) {
        self.urlSession = urlSession
        self.tokenStorage = tokenStorage
    }
    
    func fetchChartDistribution(organizationId: String, dateType: Int) async throws -> DashboardChartDistributionResponseDTO {
        // Build URL
        let endpoint = "/dashboard/asset/healthscore/organization/distributionall/\(organizationId)/\(dateType)"
        let urlString = baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            throw AuthError.invalidURL
        }
        
        print("🌐 DashboardNetworkDataSource: Fetching chart distribution from: \(urlString)")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization header
        if let token = tokenStorage.getToken() {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            // Check HTTP status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            print("📊 DashboardNetworkDataSource: HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ DashboardNetworkDataSource: HTTP Error: \(httpResponse.statusCode)")
                throw AuthError.serverError("HTTP Error: \(httpResponse.statusCode)", errorCode: httpResponse.statusCode)
            }
            
            // Debug: Print response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("📋 DashboardNetworkDataSource: Response: \(responseString)")
            }
            
            // Parse response
            let decoder = JSONDecoder()
            let responseDTO = try decoder.decode(DashboardChartDistributionResponseDTO.self, from: data)
            
            print("✅ DashboardNetworkDataSource: Successfully parsed chart distribution response")
            return responseDTO
            
        } catch let decodingError as DecodingError {
            print("❌ DashboardNetworkDataSource: Decoding error: \(decodingError)")
            throw AuthError.invalidResponse
        } catch let error as AuthError {
            print("❌ DashboardNetworkDataSource: Auth error: \(error)")
            throw error
        } catch {
            print("❌ DashboardNetworkDataSource: Network error: \(error)")
            throw AuthError.networkError
        }
    }
    
    func fetchSystemAlarmTrend(organizationId: String, dateType: Int, resolutionType: Int) async throws -> SystemAlarmTrendResponseDTO {
        // Build URL
        let endpoint = "/dashboard/alarms/systemAlarms/organization/trend/\(organizationId)/\(dateType)/\(resolutionType)"
        let urlString = baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            throw AuthError.invalidURL
        }
        
        print("🌐 DashboardNetworkDataSource: Fetching system alarm trend from: \(urlString)")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization header
        if let token = tokenStorage.getToken() {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            // Check HTTP status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            print("📊 DashboardNetworkDataSource: System Alarm Trend HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ DashboardNetworkDataSource: System Alarm Trend HTTP Error: \(httpResponse.statusCode)")
                throw AuthError.serverError("HTTP Error: \(httpResponse.statusCode)", errorCode: httpResponse.statusCode)
            }
            
            // Debug: Print response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("📋 DashboardNetworkDataSource: System Alarm Trend Response: \(responseString)")
            }
            
            // Parse response
            let decoder = JSONDecoder()
            let responseDTO = try decoder.decode(SystemAlarmTrendResponseDTO.self, from: data)
            
            print("✅ DashboardNetworkDataSource: Successfully parsed system alarm trend response")
            return responseDTO
            
        } catch let decodingError as DecodingError {
            print("❌ DashboardNetworkDataSource: System Alarm Trend Decoding error: \(decodingError)")
            throw AuthError.invalidResponse
        } catch let error as AuthError {
            print("❌ DashboardNetworkDataSource: System Alarm Trend Auth error: \(error)")
            throw error
        } catch {
            print("❌ DashboardNetworkDataSource: System Alarm Trend Network error: \(error)")
            throw AuthError.networkError
        }
    }
    
    func fetchSystemHealthScoreTrend(organizationId: String, dateType: Int, resolutionType: Int) async throws -> HealthScoreTrendResponseDTO {
        // Build URL
        let endpoint = "/dashboard/asset/healthscore/organization/trend/\(organizationId)/\(dateType)/\(resolutionType)"
        let urlString = baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            throw AuthError.invalidURL
        }
        
        print("🌐 DashboardNetworkDataSource: Fetching system health score trend from: \(urlString)")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization header
        if let token = tokenStorage.getToken() {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            // Check HTTP status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            print("📊 DashboardNetworkDataSource: System Health Score Trend HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ DashboardNetworkDataSource: System Health Score Trend HTTP Error: \(httpResponse.statusCode)")
                throw AuthError.serverError("HTTP Error: \(httpResponse.statusCode)", errorCode: httpResponse.statusCode)
            }
            
            // Debug: Print response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("📋 DashboardNetworkDataSource: System Health Score Trend Response: \(responseString)")
            }
            
            // Parse response
            let decoder = JSONDecoder()
            let responseDTO = try decoder.decode(HealthScoreTrendResponseDTO.self, from: data)
            
            print("✅ DashboardNetworkDataSource: Successfully parsed system health score trend response")
            return responseDTO
            
        } catch let decodingError as DecodingError {
            print("❌ DashboardNetworkDataSource: System Health Score Trend Decoding error: \(decodingError)")
            throw AuthError.invalidResponse
        } catch let error as AuthError {
            print("❌ DashboardNetworkDataSource: System Health Score Trend Auth error: \(error)")
            throw error
        } catch {
            print("❌ DashboardNetworkDataSource: System Health Score Trend Network error: \(error)")
            throw AuthError.networkError
        }
    }
} 