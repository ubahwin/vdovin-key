import SwiftUI

struct StartView: View {
    @EnvironmentObject private var coordinator: Coordinator

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("VdovinKey")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding()

            Spacer()

            Button {
                coordinator.push(page: .login)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .frame(height: 60)
                        .padding(.horizontal)

                    Text("Войти")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }

            Button {
                coordinator.push(page: .signup)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                        .strokeBorder(.black, lineWidth: 1)
                        .frame(height: 60)
                        .padding()

                    Text("Регистрация")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }

            Spacer()
        }
    }
}

#Preview {
    StartView()
}
