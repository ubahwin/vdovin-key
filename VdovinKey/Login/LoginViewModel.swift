import SwiftUI

final class LoginViewModel: ObservableObject {
    private let coordinator: Coordinator

    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }

    @Published var username: String = ""
    @Published var password: String = ""

    var loginIsEnabled: Bool {
        !username.isEmpty && !password.isEmpty
    }

    func login() async {
        do {
            let response: SignInResponse = try await NetworkManager.shared.signIn(
                username: username,
                password: password
            )

            if response.success {
                Storage.standard.saveNewSession(
                    username: username,
                    password: password,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    expiresAt: response.expiresAt
                )

                await coordinator.popToRoot()
                await coordinator.presentFull(.main)
            } else {
                await coordinator.showError(error: .userAlreadyExists)
            }
        } catch {
            Task { @MainActor in
                coordinator.showError(error: .userAlreadyExists)
            }
        }
    }
}
