import SwiftUI
import Combine

final class MainViewModel: ObservableObject {
    private let coordinator: Coordinator
    let user: User

    @AppStorage(Storage.isLoginnedKey) var isLoginned: Bool = false

    var scannedCode = PassthroughSubject<String, Never>()
    private var cancellable = Set<AnyCancellable>()

    init(coordinator: Coordinator) {
        self.coordinator = coordinator

        if let user = Storage.standard.getCurrentUser() {
            self.user = user
        } else {
            Storage.standard.clearSession()
            isLoginned = false
            self.user = ._stub
        }

        bind()
    }

    private func bind() {
        scannedCode.sink { [weak self] code in
            guard let self else { return }

            let tapticFeedback = UINotificationFeedbackGenerator()
            tapticFeedback.notificationOccurred(.success)

            Task { @MainActor [weak self] in
                guard let self else { return }
                await self.send(self.prepare(code))
            }
        }
        .store(in: &cancellable)
    }

    private func send(_ code: String) async {
        do {
            let response: CodeResponse = try await NetworkManager.shared.sendCode(code)

            if response.success {
                await coordinator.popToRoot()
            } else {
                await coordinator.showError(error: .sendingCodeError)
            }
        } catch {
            Task { @MainActor in
                coordinator.showError(error: .networkError)
            }
        }
    }

    private func prepare(_ code: String) -> String {
        // TODO: Implement base64 / PKCE
        code
    }
}
