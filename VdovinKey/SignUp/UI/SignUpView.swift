import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel

    var body: some View {
        Form {
            HStack {
                Text("Username")
                TextField("user", text: $viewModel.username)
            }
            HStack {
                Text("Password")
                TextField("hardpass", text: $viewModel.password)
            }

            Section("other") {
                HStack {
                    Text("First name")
                    TextField("Ivan", text: $viewModel.firstName)
                }
                HStack {
                    Text("Last name")
                    TextField("Vdovin", text: $viewModel.lastName)
                }
                HStack {
                    Text("Phone")
                    TextField("980...", text: $viewModel.phone)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("e-mail")
                    TextField("some@domain", text: $viewModel.email)
                }
            }
        }
        .navigationTitle("Sign Up")
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await viewModel.register() }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.registerIsEnabled ? .blue : .gray)
                        .frame(height: 60)
                        .padding()

                    Text("Sign Up")
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
