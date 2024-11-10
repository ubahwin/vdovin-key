
struct SignInResponse: Decodable {
    let success: Bool
    let accessToken: String
    let refreshToken: String
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case success
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
    }
}
