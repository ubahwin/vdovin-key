import SwiftUI
import Combine

final class MainViewModel: ObservableObject {
    private let coordinator: Coordinator

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

    let user: User

    private func bind() {
        scannedCode.sink { [weak self] code in
            guard let self else { return }

            self.send(self.prepare(code))
        }
        .store(in: &cancellable)
    }

    private func send(_ code: String) {
        print(code)
    }

    private func prepare(_ code: String) -> String {
        code
    }
}
