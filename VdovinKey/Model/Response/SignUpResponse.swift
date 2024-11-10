import Foundation

struct SignUpResponse: Decodable {
    let success: Bool
    let userID: UUID
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case success
        case userID = "user_id"
        case comment
    }
}
