
struct SignInResponse: Decodable {
    let success: Bool
    let accessToken: String
    let refreshToken: String
    let expiresAt: String
    let user: UserResponse

    enum CodingKeys: String, CodingKey {
        case success
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case user
    }
}

struct UserResponse: Decodable {
    let username: String
    let firstName: String
    let lastName: String
    let phone: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case phone
        case email
    }

    var mapToModel: User {
        .init(username: username, firstName: firstName, lastName: lastName, phone: phone, email: email)
    }
}
