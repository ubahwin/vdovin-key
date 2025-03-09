import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

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
        }
        .navigationTitle("Вход")
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await viewModel.login() }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.loginIsEnabled ? .blue : .gray)
                        .frame(height: 60)
                        .padding()

                    Text("Войти")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .disabled(!viewModel.loginIsEnabled)
        }
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(coordinator: Coordinator()))
        .environmentObject(Coordinator())
}
