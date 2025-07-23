import Foundation

// MARK: - Network Data Source Protocol
protocol AuthNetworkDataSourceProtocol {
    func login(request: LoginRequestDTO) async throws -> LoginResponseDTO
    func forgotPassword(request: ForgotPasswordRequestDTO) async throws -> BaseResponseDTO
    func verifyCode(request: ForgotPasswordRequestDTO) async throws -> Bool
}

// MARK: - Network Data Source Implementation
class AuthNetworkDataSource: AuthNetworkDataSourceProtocol {
    
    private let baseURL = "https://mateapi.fizix.ai/api/v1"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // MARK: - Helper Methods
    private func createAuthorizedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization token if available
        if let token = DIContainer.shared.getCurrentToken() {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add organization ID as query parameter or header if needed
        if let organizationId = UserSessionManager.shared.getCurrentOrganizationId() {
            request.setValue(organizationId, forHTTPHeaderField: "X-Organization-Id")
        }
        
        return request
    }
    
    func login(request: LoginRequestDTO) async throws -> LoginResponseDTO {
        guard let url = URL(string: "\(baseURL)/auth/signin") else {
            throw AuthError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw AuthError.invalidResponse
        }
        
        let decoded = try JSONDecoder().decode(LoginResponseDTO.self, from: data)
        
        // Don't throw here, let repository handle the error response
        return decoded
    }
    
    func forgotPassword(request: ForgotPasswordRequestDTO) async throws -> BaseResponseDTO {
        guard let url = URL(string: "\(baseURL)/user/forgotPassword") else {
            throw AuthError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw AuthError.invalidResponse
        }
        
        let decoded = try JSONDecoder().decode(BaseResponseDTO.self, from: data)
        
        if decoded.hasError {
            throw AuthError.serverError(decoded.error ?? "unknown_error".localized(), errorCode: decoded.errorCode)
        }
        
        return decoded
    }
    
    func verifyCode(request: ForgotPasswordRequestDTO) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/user/forgotCodeConfirm") else {
            throw AuthError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw AuthError.invalidResponse
        }
        
        return try JSONDecoder().decode(Bool.self, from: data)
    }
} 
