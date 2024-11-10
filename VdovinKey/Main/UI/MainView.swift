import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        TabView {
            Tab {
                CameraView(viewModel: viewModel)
            } label: {
                Label("Scan", systemImage: "camera")
            }

            Tab {
                AccountView(viewModel: viewModel)
            } label: {
                Label("Account", systemImage: "person")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    MainView(viewModel: MainViewModel(coordinator: Coordinator()))
        .environmentObject(Coordinator())
}
