import Foundation

// MARK: - System History Network Data Source Protocol

protocol SystemHistoryNetworkDataSourceProtocol {
    func fetchTimelineHistory(request: TimelineHistoryRequestDTO) async throws -> [TimelineViewDTO]
}

// MARK: - System History Network Data Source Implementation

class SystemHistoryNetworkDataSource: SystemHistoryNetworkDataSourceProtocol {
    
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
    
    func fetchTimelineHistory(request: TimelineHistoryRequestDTO) async throws -> [TimelineViewDTO] {
        // Build URL
        guard let url = URL(string: "\(baseURL)/mobile/history") else {
            throw APIError.invalidResponse("Invalid URL")
        }
        
        print("📋 Request: systemId=\(request.systemId), recordType=\(request.recordType), skip=\(request.skip), take=\(request.take)")
        
        // Create request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header
        if let token = tokenStorage.getToken() {
            urlRequest.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
            print("🔐 SystemHistoryNetworkDataSource: Added authorization header")
        }
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            print("📡 SystemHistoryNetworkDataSource: HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                throw AuthError.serverError("HTTP Error: \(httpResponse.statusCode)", errorCode: httpResponse.statusCode)
            }
            
            let historyResponse = try JSONDecoder().decode([TimelineViewDTO].self, from: data)
            
            // Log response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 SystemHistoryNetworkDataSource: Response: \(responseString.prefix(500))...")
            }
            
            return historyResponse
            
        } catch let decodingError as DecodingError {
            print("❌ SystemHistoryNetworkDataSource: History decoding error: \(decodingError)")
            throw AuthError.invalidResponse
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ SystemNetworkDataSource: History network error: \(error)")
            throw AuthError.networkError
        }
    }
} 
