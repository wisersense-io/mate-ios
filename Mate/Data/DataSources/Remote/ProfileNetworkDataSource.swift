import Foundation

// MARK: - Profile Network Data Source Protocol
protocol ProfileNetworkDataSourceProtocol {
    func changePassword(oldPassword: String, newPassword: String) async throws -> ChangePasswordResponse
}

// MARK: - Profile Network Data Source Implementation
class ProfileNetworkDataSource: ProfileNetworkDataSourceProtocol {
    
    private let baseURL = "https://mateapi.fizix.ai/api/v1"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        // Create custom URLSession configuration
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        
        self.urlSession = URLSession(configuration: config)
    }
    
    func changePassword(oldPassword: String, newPassword: String) async throws -> ChangePasswordResponse {
        print("🔍 Starting changePassword...")
        
        // Check if user is logged in
        let isLoggedIn = DIContainer.shared.isUserLoggedIn()
        print("👤 User logged in: \(isLoggedIn)")
        
        // Check current token
        guard let token = DIContainer.shared.getCurrentToken() else {
            print("❌ No token found!")
            throw APIError.invalidResponse("No authentication token found")
        }
        
        print("🔑 Token exists: \(token.accessToken.prefix(20))...")
        
        // Create URL for password change
        let urlString = "\(baseURL)/user/changePassword"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw APIError.invalidResponse("Invalid URL")
        }
        
        // Create request body
        let requestBody = ChangePasswordRequest(
            oldPassword: oldPassword,
            newPassword: newPassword
        )
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            // Encode request body
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            print("🚀 Making Change Password API Request:")
            print("URL: \(url.absoluteString)")
            print("Headers: \(request.allHTTPHeaderFields ?? [:])")
            
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
            
            // Decode response
            let decoder = JSONDecoder()
            let responseDTO = try decoder.decode(ChangePasswordResponse.self, from: data)
            print("✅ Change Password response decoded successfully: \(responseDTO)")
            return responseDTO
            
        } catch let decodingError as DecodingError {
            print("❌ Decoding Error Details:")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("Value of type '\(type)' not found: \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("Type '\(type)' mismatch: \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            throw APIError.decodingError
        } catch {
            print("❌ URLSession Error Details:")
            print("Error: \(error)")
            throw APIError.networkError
        }
    }
} 