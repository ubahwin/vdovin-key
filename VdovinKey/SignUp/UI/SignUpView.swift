import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel

    var body: some View {
        Form {
            HStack {
                Text("Логин")
                TextField("user", text: $viewModel.username)
            }
            HStack {
                Text("Пароль")
                TextField("hardpass", text: $viewModel.password)
            }

            Section("Другое") {
                HStack {
                    Text("Имя")
                    TextField("Ivan", text: $viewModel.firstName)
                }
                HStack {
                    Text("Фамилия")
                    TextField("Vdovin", text: $viewModel.lastName)
                }
                HStack {
                    Text("Телефон")
                    TextField("980...", text: $viewModel.phone)
                }
                HStack {
                    Text("e-mail")
                    TextField("some@domain", text: $viewModel.email)
                }
            }
        }
        .navigationTitle("Регистрация")
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await viewModel.register() }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.registerIsEnabled ? .blue : .gray)
                        .frame(height: 60)
                        .padding()

                    Text("Зарегистрироваться")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .disabled(!viewModel.registerIsEnabled)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(viewModel: SignUpViewModel(coordinator: Coordinator()))
    }
}
