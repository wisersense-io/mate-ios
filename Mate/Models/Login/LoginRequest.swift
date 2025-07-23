struct LoginRequest: Encodable {
    let email: String
    let password: String
    let isMobile: Bool
}
