import Foundation

// MARK: - Organization Network Data Source

class OrganizationNetworkDataSource {
    private let session = URLSession.shared
    private let tokenStorage: TokenStorageServiceProtocol
    
    init(tokenStorage: TokenStorageServiceProtocol) {
        self.tokenStorage = tokenStorage
    }
    
    func getOrganizations() async throws -> [OrganizationResponseDTO] {
        let urlString = "https://mateapi.fizix.ai/api/v1/mobile/organizations"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization header
        if let token = tokenStorage.getToken()?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            let organizations = try JSONDecoder().decode([OrganizationResponseDTO].self, from: data)
            print("✅ OrganizationNetworkDataSource: Successfully fetched \(organizations.count) organizations")
            
            return organizations
            
        } catch let decodingError as DecodingError {
            print("❌ OrganizationNetworkDataSource: Decoding error: \(decodingError)")
            throw NetworkError.decodingError
        } catch {
            print("❌ OrganizationNetworkDataSource: Network error: \(error)")
            throw NetworkError.networkError(error)
        }
    }
}

// MARK: - Network Error

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
} 