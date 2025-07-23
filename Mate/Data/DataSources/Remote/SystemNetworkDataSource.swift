import Foundation

// MARK: - System Network Data Source Protocol
protocol SystemNetworkDataSourceProtocol {
    func fetchSystems(organizationId: String, filter: Int, skip: Int, take: Int) async throws -> SystemsResponse
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
        
        print("🌐 SystemNetworkDataSource: Fetching systems from: \(urlString)")
        
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
}
