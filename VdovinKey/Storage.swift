import Foundation

final class Storage {
    static let isLoginnedKey = "isLoginned"
    static let passwordKey = "password"
    static let usernameKey = "username"
    static let accessTokenKey = "accessToken"
    static let refreshTokenKey = "refreshToken"
    static let expiresAtKey = "expiresAt"

    private let userDefaults = UserDefaults.standard

    func saveNewSession(username: String, password: String, accessToken: String, refreshToken: String, expiresAt: String) {
        userDefaults.set(true, forKey: Storage.isLoginnedKey)
        userDefaults.set(username, forKey: Storage.usernameKey)
        userDefaults.set(password, forKey: Storage.passwordKey)
        userDefaults.set(accessToken, forKey: Storage.accessTokenKey)
        userDefaults.set(refreshToken, forKey: Storage.refreshTokenKey)
        userDefaults.set(expiresAt, forKey: Storage.expiresAtKey)
    }

    func clearSession() {
        userDefaults.removeObject(forKey: Storage.isLoginnedKey)
        userDefaults.removeObject(forKey: Storage.usernameKey)
        userDefaults.removeObject(forKey: Storage.passwordKey)
        userDefaults.removeObject(forKey: Storage.accessTokenKey)
        userDefaults.removeObject(forKey: Storage.refreshTokenKey)
        userDefaults.removeObject(forKey: Storage.expiresAtKey)
    }

    static var tokenIsRotten: Bool {
        true
    }

    static var refreshToken: String? {
        UserDefaults.standard.string(forKey: refreshTokenKey)
    }

    static let standard = Storage()
    private init() {}
}
