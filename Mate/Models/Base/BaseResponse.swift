struct BaseResponse: Decodable {
    let error: String?
    let errorCode: Int
    
    var hasError: Bool {
        return !(error?.isEmpty ?? true) || errorCode != 0
    }
}
