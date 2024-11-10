import SwiftUI

struct AccountView: View {
    @EnvironmentObject var coordinator: Coordinator
    @AppStorage(Storage.isLoginnedKey) var isLoginned: Bool = false
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        List {
            Section("Info") {
                HStack {
                    Text("Username")
                    Spacer()
                    Text("ubah")
                }
                HStack {
                    Text("First name")
                    Spacer()
                    Text("Ivan")
                }
                HStack {
                    Text("Last name")
                    Spacer()
                    Text("Vdovin")
                }
                HStack {
                    Text("Phone")
                    Spacer()
                    Text("9803532589")
                }
                HStack {
                    Text("e-mail")
                    Spacer()
                    Text("ivan@city.com")
                }
            }

            Section("Actions") {
                HStack {
                    Spacer()
                    Button {
                        isLoginned = false
                        coordinator.dismissCover()
                    } label: {
                        ZStack {
                            Text("Logout")
                                .foregroundStyle(.red)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    AccountView(viewModel: MainViewModel(coordinator: .init()))
        .environmentObject(Coordinator())
}
