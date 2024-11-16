import SwiftUI

struct AccountView: View {
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        List {
            Section("Info") {
                HStack {
                    Text("Username")
                    Spacer()
                    Text(viewModel.user.username)
                }
                HStack {
                    Text("First name")
                    Spacer()
                    Text(viewModel.user.firstName)
                }
                HStack {
                    Text("Last name")
                    Spacer()
                    Text(viewModel.user.lastName)
                }
                HStack {
                    Text("Phone")
                    Spacer()
                    Text(viewModel.user.phone)
                }
                HStack {
                    Text("e-mail")
                    Spacer()
                    Text(viewModel.user.email)
                }
            }

            Section("Actions") {
                HStack {
                    Spacer()
                    Button {
                        viewModel.isLoginned = false
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
//
//#Preview {
//    AccountView(viewModel: MainViewModel(coordinator: .init()))
//        .environmentObject(Coordinator())
//}
