import Foundation

struct SignUpRequest: Encodable {
    let username: String
    let password: String
    let firstName: String
    let lastName: String
    let phone: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case username
        case password
        case firstName = "first_name"
        case lastName = "last_name"
        case phone
        case email
    }
}
