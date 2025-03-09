import SwiftUI

@main
struct VdovinKeyApp: App {
    @StateObject private var coordinator = Coordinator()
    @AppStorage(Storage.isLoginnedKey) var isLoginned: Bool = false

    private var launchedPage: AppPages {
        guard isLoginned else {
            return .start
        }

        guard coordinator.isUnlocked else {
            return .bimetricPage
        }

        return .main
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                coordinator.build(page: launchedPage)
                    .navigationDestination(for: AppPages.self) { page in
                        coordinator.build(page: page)
                    }
                    .fullScreenCover(item: $coordinator.fullScreenCover) { item in
                        coordinator.build(page: item)
                    }
                    .sheet(item: $coordinator.sheet) { item in
                        coordinator.build(page: item)
                    }
                    .alert(item: $coordinator.errorAlert) { error in
                        coordinator.buildError(error: error)
                    }
            }
            .preferredColorScheme(.light)
            .environmentObject(coordinator)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                coordinator.presentFull(.main)
            }
            .onAppear {
                checkForLogout()
            }
        }
    }

    // TODO: Implement me
    private func checkForLogout() {
        guard
            isLoginned,
            Storage.tokenIsRotten,
            let refreshToken = Storage.refreshToken
        else {
            return
        }

        Task {
            do {
//                        try await NetworkManager.shared.refreshSession(
//                            refreshToken: refreshToken
//                        )
            } catch {
                coordinator.showError(error: .networkError)
            }
        }
    }
}
