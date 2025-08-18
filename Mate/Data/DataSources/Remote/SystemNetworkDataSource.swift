import Foundation

// MARK: - System Network Data Source Protocol
protocol SystemNetworkDataSourceProtocol {
    func fetchSystems(organizationId: String, filter: Int, skip: Int, take: Int) async throws -> SystemsResponse
    func fetchSystemHealthScoreTrend(systemId: String, dateType: Int) async throws -> SystemDetailTrendResponse
    func fetchSystemLastDiagnosis(systemId: String, dateType: Int) async throws -> WidgetListResult<LastDiagnosisResponseDTO>
}

// MARK: - System Network Data Source Implementation
class SystemNetworkDataSource: SystemNetworkDataSourceProtocol {
    
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
    
    func fetchSystems(organizationId: String, filter: Int, skip: Int, take: Int) async throws -> SystemsResponse {
        // Build URL
        let endpoint = "/mobile/systems"
        let urlString = "\(baseURL)\(endpoint)/\(organizationId)/\(filter)/\(skip)/\(take)"
        
        guard let url = URL(string: urlString) else {
            throw AuthError.invalidURL
        }
        
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
            
            guard httpResponse.statusCode == 200 else {
                throw AuthError.serverError("HTTP Error: \(httpResponse.statusCode)", errorCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            let systemsResponse = try decoder.decode(SystemsResponse.self, from: data)
            
            return systemsResponse
            
        } catch let decodingError as DecodingError {
            print("❌ SystemNetworkDataSource: Decoding error: \(decodingError)")
            throw AuthError.invalidResponse
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ SystemNetworkDataSource: Network error: \(error)")
            throw AuthError.networkError
        }
    }
    
    func fetchSystemHealthScoreTrend(systemId: String, dateType: Int) async throws -> SystemDetailTrendResponse {
        // Build URL
        let endpoint = "/mobile/systems/trend/healthScore"
        let urlString = "\(baseURL)\(endpoint)/\(systemId)/\(dateType)"
        
        guard let url = URL(string: urlString) else {
            throw AuthError.invalidURL
        }
        
        // Create request with timeout
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30.0 // 30 seconds timeout
        
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
            
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                break // Success
            case 401:
                throw AuthError.serverError("Authentication failed. Please login again.", errorCode: 401)
            case 403:
                throw AuthError.serverError("Access denied. You don't have permission to view this data.", errorCode: 403)
            case 404:
                throw AuthError.serverError("System not found or trend data unavailable.", errorCode: 404)
            case 500...599:
                throw AuthError.serverError("Server error. Please try again later.", errorCode: httpResponse.statusCode)
            default:
                throw AuthError.serverError("HTTP Error: \(httpResponse.statusCode)", errorCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            let trendResponse = try decoder.decode(SystemDetailTrendResponse.self, from: data)
            
            return trendResponse
            
        } catch let decodingError as DecodingError {
            print("❌ SystemNetworkDataSource: System health score trend decoding error: \(decodingError)")
            throw AuthError.invalidResponse
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ SystemNetworkDataSource: System health score trend network error: \(error)")
            throw AuthError.networkError
        }
    }
    
    func fetchSystemLastDiagnosis(systemId: String, dateType: Int) async throws -> WidgetListResult<LastDiagnosisResponseDTO> {
        // Build URL
        let endpoint = "/diagnosis/system/lastDiagnosis"
        let urlString = "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            throw AuthError.invalidURL
        }
        
        print("🌐 SystemNetworkDataSource: Fetching system last diagnosis from: \(urlString)")
        print("🔍 SystemNetworkDataSource: Request systemId: \(systemId), dateType: \(dateType)")
        
        // Create request body
        let requestBody = LastDiagnosisRequestDTO(systemId: systemId, dateType: dateType)
        
        // Create request with timeout
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30.0 // 30 seconds timeout
        
        // Add authorization header
        if let token = tokenStorage.getToken() {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Encode request body
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(requestBody)
            request.httpBody = jsonData
            
            print("🔍 SystemNetworkDataSource: Request body: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")
        } catch {
            print("❌ SystemNetworkDataSource: Failed to encode request body: \(error)")
            throw AuthError.networkError
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            // Check HTTP status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                break // Success
            case 401:
                throw AuthError.serverError("Authentication failed. Please login again.", errorCode: 401)
            case 403:
                throw AuthError.serverError("Access denied. You don't have permission to view this data.", errorCode: 403)
            case 404:
                throw AuthError.serverError("System not found or diagnosis data unavailable.", errorCode: 404)
            case 500...599:
                throw AuthError.serverError("Server error. Please try again later.", errorCode: httpResponse.statusCode)
            default:
                throw AuthError.serverError("HTTP Error: \(httpResponse.statusCode)", errorCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            let diagnosisResponse = try decoder.decode(WidgetListResult<LastDiagnosisResponseDTO>.self, from: data)
            
            print("✅ SystemNetworkDataSource: Successfully fetched \(diagnosisResponse.data?.count ?? 0) diagnosis items")
            
            return diagnosisResponse
            
        } catch let decodingError as DecodingError {
            print("❌ SystemNetworkDataSource: System last diagnosis decoding error: \(decodingError)")
            throw AuthError.invalidResponse
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ SystemNetworkDataSource: System last diagnosis network error: \(error)")
            throw AuthError.networkError
        }
    }
}
