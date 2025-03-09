import SwiftUI

struct BiometricsView: View {
    let authenticate: () -> Void

    var body: some View {
        VStack(spacing: .zero) {
            Spacer()

            Text("VdovinKey")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding()

            Spacer()

            Image(systemName: "person.fill.questionmark")
                .resizable()
                .scaledToFit()
                .frame(height: 44)

            Text("Пожалуйста, подтвердите вашу личность по лицу или отпечатку пальца.")
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button {
                authenticate()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .frame(height: 60)
                        .padding(.horizontal)

                    Text("Подтвердить")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }

            Spacer()
        }
    }
}

#Preview {
    BiometricsView(authenticate: { print("authenticate") })
        .environmentObject(Coordinator())
}

