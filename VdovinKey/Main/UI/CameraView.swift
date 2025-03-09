import SwiftUI

struct CameraView: View {
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        ZStack {
#if targetEnvironment(simulator)
            Color.blue
#else
            CodeScannerView(
                codeTypes: [.qr],
                scanMode: .continuous,
                shouldVibrateOnSuccess: false
            ) { response in
                switch response {
                case .success(let result):
                    viewModel.scannedCode.send(result.string)
                case .failure:
                    coordinator.showError(error: .qrValidateError)
                }
            }
#endif

            Color.black.opacity(0.6)
                .mask(
                    ZStack {
                        Rectangle()
                            .fill(Color.white)

                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 240, height: 240)
                            .blendMode(.destinationOut)
                    }
                )
        }
        .mask(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
    }
}

#Preview {
    CameraView(viewModel: MainViewModel(coordinator: .init()))
        .environmentObject(Coordinator())
}

#Preview {
    MainView(viewModel: MainViewModel(coordinator: Coordinator()))
        .environmentObject(Coordinator())
}
