import SwiftUI
import LocalAuthentication

enum AppPages: Hashable, Identifiable {
    var id: Int {
        self.hashValue
    }

    case start
    case bimetricPage
    case login
    case signup
    case main
}

enum ErrorAlert: String, Identifiable {
    var id: String {
        self.rawValue
    }

    case userAlreadyExists = "Такой пользователь уже существует"
    case wrongPassword = "Неверный пароль"
    case userNotFound = "Пользователь не найден"
    case networkError = "Ошибка сети"
    case qrValidateError = "QR-код не валиден"
    case sendingCodeError = "Отправка QR-кода не удалась"
}

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var errorAlert: ErrorAlert?
    @Published var fullScreenCover: AppPages?
    @Published var sheet: AppPages?

    @Published var isUnlocked: Bool = false

    @MainActor
    func push(page: AppPages) {
        path.append(page)
    }

    @MainActor
    func pop() {
        path.removeLast()
    }

    @MainActor
    func popToRoot() {
        path.removeLast(path.count)
    }

    @MainActor
    func presentFull(_ cover: AppPages) {
        self.fullScreenCover = cover
    }

    @MainActor
    func dismissCover() {
        self.fullScreenCover = nil
    }

    @MainActor
    func present(_ cover: AppPages) {
        self.sheet = cover
    }

    @MainActor
    func dismissSheet() {
        self.sheet = nil
    }

    @MainActor
    func showError(error: ErrorAlert) {
        self.errorAlert = error
    }

    @ViewBuilder
    func build(page: AppPages) -> some View {
        switch page {
        case .start:
            StartView()
        case .signup:
            SignUpView(viewModel: SignUpViewModel(coordinator: self))
        case .login:
            LoginView(viewModel: LoginViewModel(coordinator: self))
        case .main:
            MainView(viewModel: MainViewModel(coordinator: self))
        case .bimetricPage:
            BiometricsView(authenticate: authenticate)
        }
    }

    func buildError(error: ErrorAlert) -> Alert {
        Alert(
            title: Text("Error"),
            message: Text(error.rawValue)
        )
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Пожалуйста, подтвердите свою личность."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    Task { @MainActor [weak self] in
                        self?.isUnlocked = true
                    }
                }
            }
        }
    }
}
