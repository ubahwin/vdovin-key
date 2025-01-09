import Foundation

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case requestFailed
    case decodingError
    case serverError(statusCode: Int)
}

class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    private func request<T: Decodable, U: Encodable>(
        urlString: String,
        method: String = "GET",
        headers: [String: String]? = nil,
        body: U? = nil
    ) async throws -> T {
        let isLoggingEnabled = Constants.isLoggingEnabled

        guard let url = URL(string: urlString) else {
            if isLoggingEnabled { print("[ERROR] Invalid URL: \(urlString)") }
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = body {
            do {
                let encodedBody = try JSONEncoder().encode(body)
                request.httpBody = encodedBody
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                if isLoggingEnabled { print("[ERROR] Failed to encode request body: \(error)") }
                throw NetworkError.decodingError
            }
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                if isLoggingEnabled { print("[ERROR] Invalid response") }
                throw NetworkError.requestFailed
            }

            if isLoggingEnabled {
                var log = "[REQUEST] \nURL: \(urlString)\nMethod: \(method)\nHeaders: \(headers ?? [:])"
                if let body = body, let bodyString = String(data: try JSONEncoder().encode(body), encoding: .utf8) {
                    log += "\nBody: \(bodyString)"
                }
                log += "\n[RESPONSE]\nStatus Code: \(httpResponse.statusCode)\nData: \(String(data: data, encoding: .utf8) ?? "<no data>")"
                print(log)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData

        } catch let error as NetworkError {
            if isLoggingEnabled { print("[ERROR] Network Error: \(error)") }
            throw error
        } catch {
            if isLoggingEnabled { print("[ERROR] Unexpected Error: \(error)") }
            throw NetworkError.decodingError
        }
    }

    func signUp(
        username: String,
        password: String,
        firstName: String,
        lastName: String,
        phone: String,
        email: String
    ) async throws -> SignUpResponse {
        let user = SignUpRequest(
            username: username,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            email: email
        )

        return try await NetworkManager.shared.request(
            urlString: Constants.URL.signup,
            method: "POST",
            body: user
        )
    }

    func signIn(username: String, password: String) async throws -> SignInResponse {
        let user = SignInRequest(
            username: username,
            password: password
        )

        return try await request(
            urlString: Constants.URL.signin,
            method: "POST",
            body: user
        )
    }

    func sendCode(_ code: String) async throws -> CodeResponse {
        guard let token = SecureStorage.shared.getPassword(for: Storage.accessTokenKey) else {
            throw NetworkError.unauthorized
        }

        let body = CodeRequest(
            token: token,
            code: code
        )

        return try await request(
            urlString: Constants.URL.code,
            method: "POST",
            body: body
        )
    }

    // TODO: Implement me
//    func refreshSession(refreshToken: String) async throws -> ... {
//        let user = ...(
//            refreshToken: refreshToken
//        )
//
//        return try await request(
//            urlString: "http://localhost:8080/user/refreshSession",
//            method: "POST",
//            body: user
//        )
//    }
}
