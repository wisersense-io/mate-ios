struct ForgotPasswordRequest: Encodable {
    let eMailAddress: String
    let verificationCode: String
}
