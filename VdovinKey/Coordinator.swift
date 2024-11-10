import SwiftUI

enum AppPages: Hashable, Identifiable {
    var id: Int {
        self.hashValue
    }

    case start
    case login
    case signup
    case main
}

enum ErrorAlert: String, Identifiable {
    var id: String {
        self.rawValue
    }

    case userAlreadyExists = "User already exists"
    case wrongPassword = "Wrong password"
    case userNotFound = "User not found"
    case networkError = "Network error"
    case qrValidateError = "QR code validation error"
}

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var errorAlert: ErrorAlert?
    @Published var fullScreenCover: AppPages?
    @Published var sheet: AppPages?

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
        }
    }

    func buildError(error: ErrorAlert) -> Alert {
        Alert(
            title: Text("Error"),
            message: Text(error.rawValue)
        )
    }
}
