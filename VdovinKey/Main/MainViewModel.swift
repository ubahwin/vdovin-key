import SwiftUI
import Combine

final class MainViewModel: ObservableObject {
    private let coordinator: Coordinator

    var scannedCode = PassthroughSubject<String, Never>()
    private var cancellable = Set<AnyCancellable>()

    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        bind()
    }

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
