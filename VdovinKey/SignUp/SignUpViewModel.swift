import SwiftUI

final class SignUpViewModel: ObservableObject {
    private let coordinator: Coordinator

    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }

    @Published var username: String = ""
    @Published var password: String = ""

    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""

    var registerIsEnabled: Bool {
        !username.isEmpty &&
        !password.isEmpty &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !phone.isEmpty
    }

    func register() async {
        do {
            let response: SignUpResponse = try await NetworkManager.shared.signUp(
                username: username,
                password: password,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                email: email
            )

            if response.success {
                await coordinator.pop()
                await coordinator.push(page: .login)
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
