import SwiftUI

@main
struct VdovinKeyApp: App {
    @StateObject private var coordinator = Coordinator()
    @AppStorage(Storage.isLoginnedKey) var isLoginned: Bool = false

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                coordinator.build(page: isLoginned ? .main : .start)
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

            // TODO: realize
            .onAppear {
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
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}
