import Foundation

final class Storage {
    static let isLoginnedKey = "isLoginned"
    static let passwordKey = "password"
    static let accessTokenKey = "accessToken"
    static let refreshTokenKey = "refreshToken"
    static let expiresAtKey = "expiresAt"

    // MARK: – User

    static let usernameKey = "username"
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let phoneKey = "phone"
    static let emailKey = "email"

    private let userDefaults = UserDefaults.standard
    private let secretStorage = SecureStorage.shared

    func saveNewSession(password: String, accessToken: String, refreshToken: String, expiresAt: String) {
        userDefaults.set(true, forKey: Storage.isLoginnedKey)
        secretStorage.updatePassword(password, for: Storage.passwordKey)
        secretStorage.updatePassword(accessToken, for: Storage.accessTokenKey)
        secretStorage.updatePassword(refreshToken, for: Storage.refreshTokenKey)
        userDefaults.set(expiresAt, forKey: Storage.expiresAtKey)
    }

    func saveNewUser(_ user: User) {
        userDefaults.set(user.username, forKey: Storage.usernameKey)
        userDefaults.set(user.firstName, forKey: Storage.firstNameKey)
        userDefaults.set(user.lastName, forKey: Storage.lastNameKey)
        userDefaults.set(user.phone, forKey: Storage.phoneKey)
        userDefaults.set(user.email, forKey: Storage.emailKey)
    }

    func getCurrentUser() -> User? {
        guard
            let username = userDefaults.string(forKey: Storage.usernameKey),
            let firstName = userDefaults.string(forKey: Storage.firstNameKey),
            let lastName = userDefaults.string(forKey: Storage.lastNameKey),
            let phone = userDefaults.string(forKey: Storage.phoneKey),
            let email = userDefaults.string(forKey: Storage.emailKey)
        else { return nil }

        return User(username: username, firstName: firstName, lastName: lastName, phone: phone, email: email)
    }

    func clearSession() {
        userDefaults.removeObject(forKey: Storage.isLoginnedKey)
        userDefaults.removeObject(forKey: Storage.usernameKey)
        secretStorage.deletePassword(for: Storage.passwordKey)
        secretStorage.deletePassword(for: Storage.accessTokenKey)
        secretStorage.deletePassword(for: Storage.refreshTokenKey)
        userDefaults.removeObject(forKey: Storage.expiresAtKey)

        userDefaults.removeObject(forKey: Storage.usernameKey)
        userDefaults.removeObject(forKey: Storage.firstNameKey)
        userDefaults.removeObject(forKey: Storage.lastNameKey)
        userDefaults.removeObject(forKey: Storage.phoneKey)
        userDefaults.removeObject(forKey: Storage.emailKey)
    }

    static var tokenIsRotten: Bool {
        true
    }

    static var refreshToken: String? {
        SecureStorage.shared.getPassword(for: Storage.refreshTokenKey)
    }

    static let standard = Storage()
    private init() {}
}
