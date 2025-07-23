struct LoginResponse: Decodable {
    let token: String
    let userName: String
    let email: String
    let role: Int
    let organizationId: String
    let hasError: Bool
    let errorCode: Int
    let currentUser: CurrentUser
    
}

struct CurrentUser: Decodable {
    let name: String
    let userName: String
    let email: String
    let jobType: String
    let defaultLanguage: String
    let timeZone: String
    let id: String
}
