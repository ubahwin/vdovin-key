import Foundation

enum NetworkError: Error {
    case invalidURL
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
        guard let url = URL(string: urlString) else {
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
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.requestFailed
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            print("[NETWORK]\n", decodedData)
            return decodedData
        } catch {
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
            urlString: "http://localhost:8080/user/signUp",
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
            urlString: "http://localhost:8080/user/signIn",
            method: "POST",
            body: user
        )
    }

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
