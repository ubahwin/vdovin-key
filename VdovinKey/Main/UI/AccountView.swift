import SwiftUI

struct AccountView: View {
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        List {
            Section("Данные о пользователе") {
                HStack {
                    Text("Логин")
                    Spacer()
                    Text(viewModel.user.username)
                }
                HStack {
                    Text("Имя")
                    Spacer()
                    Text(viewModel.user.firstName)
                }
                HStack {
                    Text("Фамилия")
                    Spacer()
                    Text(viewModel.user.lastName)
                }
                HStack {
                    Text("Телефон")
                    Spacer()
                    Text(viewModel.user.phone)
                }
                HStack {
                    Text("e-mail")
                    Spacer()
                    Text(viewModel.user.email)
                }
                HStack {
                    Spacer()
                    Button {
                        viewModel.isLoginned = false
                        coordinator.dismissCover()
                    } label: {
                        ZStack {
                            Text("Выйти")
                                .foregroundStyle(.red)
                        }
                    }
                    Spacer()
                }
            }
        }
        .scrollDisabled(true)
    }
}

#Preview {
    AccountView(viewModel: MainViewModel(coordinator: .init()))
        .environmentObject(Coordinator())
}
