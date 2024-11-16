struct User {
    let username: String
    let firstName: String
    let lastName: String
    let phone: String
    let email: String

    static var _stub: Self {
        .init(username: "ubaha", firstName: "ubaha", lastName: "ubaha", phone: "ubaha", email: "ubaha")
    }
}
