import Foundation

// MARK: - Home Network Data Source Protocol
protocol HomeNetworkDataSourceProtocol {
    func fetchDashboardInfo(organizationId: String) async throws -> HomeDashboardInfoResponseDTO
    func fetchHealthScore(organizationId: String, isWeighted: Bool) async throws -> HealthScoreResponseDTO
    func fetchHealthScoreTrend(organizationId: String, dateType: DateType, resolutionType: DateResolutionType) async throws -> HealthScoreTrendResponseDTO
}

// MARK: - Home Network Data Source Implementation
class HomeNetworkDataSource: HomeNetworkDataSourceProtocol {
    
    private let baseURL = "https://mateapi.fizix.ai/api/v1"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        // Create custom URLSession configuration for better refresh handling
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        
        self.urlSession = URLSession(configuration: config)
    }
    
    func fetchDashboardInfo(organizationId: String) async throws -> HomeDashboardInfoResponseDTO {
        print("🔍 Starting fetchDashboardInfo for organizationId: \(organizationId)")
        
        // Check if user is logged in
        let isLoggedIn = DIContainer.shared.isUserLoggedIn()
        print("👤 User logged in: \(isLoggedIn)")
        
        // Check current token
        if let token = DIContainer.shared.getCurrentToken() {
            print("🔑 Token exists: \(token.accessToken.prefix(20))...")
        } else {
            print("❌ No token found!")
            throw APIError.invalidResponse("No authentication token found")
        }
        
        print("🏢 Using Organization ID: \(organizationId)")
        
        // Create URL with organization ID
        let urlString = "\(baseURL)/dashboard/mobile/totalcounts/\(organizationId)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw APIError.invalidResponse("Invalid URL")
        }
        
        // Create authorized request
        let request = createAuthorizedRequest(url: url)
        
        print("🚀 Making API Request:")
        print("URL: \(url.absoluteString)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Could not cast response to HTTPURLResponse")
                throw APIError.networkError
            }
            
            print("📊 HTTP Response:")
            print("Status Code: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
            
            // Check for HTTP errors
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ HTTP Error - Status Code: \(httpResponse.statusCode)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response Body: \(jsonString)")
                }
                throw APIError.networkError
            }
            
            // Print raw JSON response for debugging
            /*if let jsonString = String(data: data, encoding: .utf8) {
                print("📡 API Response JSON:")
                print(jsonString)
            } else {
                print("❌ Could not convert data to string")
                print("📊 Raw Data: \(data)")
            }
            */
            
            // Decode response
            let decoder = JSONDecoder()
            let responseDTO = try decoder.decode(HomeDashboardInfoResponseDTO.self, from: data)
            print("✅ Data decoded successfully: \(responseDTO)")
            return responseDTO
            
        } catch let decodingError as DecodingError {
            print("❌ Decoding Error Details:")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .valueNotFound(let type, let context):
                print("Value of type '\(type)' not found: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("Type '\(type)' mismatch: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            throw APIError.decodingError
        } catch {
            print("❌ URLSession Error Details:")
            print("Error type: \(type(of: error))")
            print("Error description: \(error.localizedDescription)")
            print("Error: \(error)")
            
            if let urlError = error as? URLError {
                print("URLError code: \(urlError.code)")
                print("URLError localized: \(urlError.localizedDescription)")
                print("URLError user info: \(urlError.userInfo)")
                
                // Handle specific URL error codes
                switch urlError.code {
                case .cancelled:
                    print("🛑 Request was cancelled by system")
                    throw APIError.invalidResponse("Request cancelled")
                case .timedOut:
                    print("⏰ Request timed out")
                    throw APIError.networkError
                case .notConnectedToInternet:
                    print("📶 No internet connection")
                    throw APIError.networkError
                default:
                    print("🌐 Other URL error: \(urlError.localizedDescription)")
                    throw APIError.networkError
                }
            }
            
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError
            }
        }
    }
    
    func fetchHealthScore(organizationId: String, isWeighted: Bool) async throws -> HealthScoreResponseDTO {
        print("🔍 Starting fetchHealthScore for organizationId: \(organizationId), isWeighted: \(isWeighted)")
        
        // Check if user is logged in
        let isLoggedIn = DIContainer.shared.isUserLoggedIn()
        print("👤 User logged in: \(isLoggedIn)")
        
        // Check current token
        if let token = DIContainer.shared.getCurrentToken() {
            print("🔑 Token exists: \(token.accessToken.prefix(20))...")
        } else {
            print("❌ No token found!")
            throw APIError.invalidResponse("No authentication token found")
        }
        
        // Create URL with organization ID and isWeighted parameters
        let urlString = "\(baseURL)/dashboard/healthscore/organization/\(organizationId)/\(isWeighted)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw APIError.invalidResponse("Invalid URL")
        }
        
        // Create authorized request
        let request = createAuthorizedRequest(url: url)
        
        print("🚀 Making Health Score API Request:")
        print("URL: \(url.absoluteString)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Could not cast response to HTTPURLResponse")
                throw APIError.networkError
            }
            
            print("📊 HTTP Response:")
            print("Status Code: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
            
            // Check for HTTP errors
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ HTTP Error - Status Code: \(httpResponse.statusCode)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response Body: \(jsonString)")
                }
                throw APIError.networkError
            }
            
            // Print raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📡 Health Score API Response JSON:")
                print(jsonString)
            }
            
            // Decode response
            let decoder = JSONDecoder()
            let responseDTO = try decoder.decode(HealthScoreResponseDTO.self, from: data)
            print("✅ Health Score data decoded successfully: \(responseDTO)")
            return responseDTO
            
        } catch let decodingError as DecodingError {
            print("❌ Health Score Decoding Error Details:")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .valueNotFound(let type, let context):
                print("Value of type '\(type)' not found: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("Type '\(type)' mismatch: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            throw APIError.decodingError
        } catch {
            print("❌ Health Score URLSession Error Details:")
            print("Error type: \(type(of: error))")
            print("Error description: \(error.localizedDescription)")
            print("Error: \(error)")
            
            if let urlError = error as? URLError {
                print("URLError code: \(urlError.code)")
                print("URLError localized: \(urlError.localizedDescription)")
                
                switch urlError.code {
                case .cancelled:
                    print("🛑 Health Score request was cancelled by system")
                    throw APIError.invalidResponse("Request cancelled")
                case .timedOut:
                    print("⏰ Health Score request timed out")
                    throw APIError.networkError
                case .notConnectedToInternet:
                    print("📶 No internet connection")
                    throw APIError.networkError
                default:
                    print("🌐 Other URL error: \(urlError.localizedDescription)")
                    throw APIError.networkError
                }
            }
            
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError
            }
        }
    }
    
    func fetchHealthScoreTrend(organizationId: String, dateType: DateType = .last7Days, resolutionType: DateResolutionType = .daily) async throws -> HealthScoreTrendResponseDTO {
        print("🔍 Starting fetchHealthScoreTrend for organizationId: \(organizationId), dateType: \(dateType.rawValue), resolutionType: \(resolutionType.rawValue)")
        
        // Check if user is logged in
        let isLoggedIn = DIContainer.shared.isUserLoggedIn()
        print("👤 User logged in: \(isLoggedIn)")
        
        // Check current token
        if let token = DIContainer.shared.getCurrentToken() {
            print("🔑 Token exists: \(token.accessToken.prefix(20))...")
        } else {
            print("❌ No token found!")
            throw APIError.invalidResponse("No authentication token found")
        }
        
        // Create URL with query parameters
        let urlString = "\(baseURL)/dashboard/system/healthscore/organization/trend/\(organizationId)/\(dateType.rawValue)/\(resolutionType.rawValue)"
        
        //let urlString = "\(baseURL)/dashboard/healthscore/organization/\(organizationId)/\(isWeighted)"
        
        
        // Create authorized request
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw APIError.invalidResponse("Invalid URL")
        }
        
        let request = createAuthorizedRequest(url: url)
        
        print("🚀 Making Health Score Trend API Request:")
        print("URL: \(url.absoluteString)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Could not cast response to HTTPURLResponse")
                throw APIError.networkError
            }
            
            print("📊 HTTP Response:")
            print("Status Code: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
            
            // Check for HTTP errors
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ HTTP Error - Status Code: \(httpResponse.statusCode)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response Body: \(jsonString)")
                }
                throw APIError.networkError
            }
            
            // Print raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📡 Health Score Trend API Response JSON:")
                print(jsonString)
            }
            
            // Decode response
            let decoder = JSONDecoder()
            let responseDTO = try decoder.decode(HealthScoreTrendResponseDTO.self, from: data)
            print("✅ Health Score Trend data decoded successfully: \(responseDTO)")
            return responseDTO
            
        } catch let decodingError as DecodingError {
            print("❌ Health Score Trend Decoding Error Details:")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .valueNotFound(let type, let context):
                print("Value of type '\(type)' not found: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("Type '\(type)' mismatch: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
                print("Coding path: \(context.codingPath)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            throw APIError.decodingError
        } catch {
            print("❌ Health Score Trend URLSession Error Details:")
            print("Error type: \(type(of: error))")
            print("Error description: \(error.localizedDescription)")
            print("Error: \(error)")
            
            if let urlError = error as? URLError {
                print("URLError code: \(urlError.code)")
                print("URLError localized: \(urlError.localizedDescription)")
                
                switch urlError.code {
                case .cancelled:
                    print("🛑 Health Score Trend request was cancelled by system")
                    throw APIError.invalidResponse("Request cancelled")
                case .timedOut:
                    print("⏰ Health Score Trend request timed out")
                    throw APIError.networkError
                case .notConnectedToInternet:
                    print("📶 No internet connection")
                    throw APIError.networkError
                default:
                    print("🌐 Other URL error: \(urlError.localizedDescription)")
                    throw APIError.networkError
                }
            }
            
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError
            }
        }
    }
    
    // MARK: - Helper Methods
    private func createAuthorizedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prevent caching issues on refresh
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 30.0
        
        // Add authorization token
        if let token = DIContainer.shared.getCurrentToken() {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
} 
