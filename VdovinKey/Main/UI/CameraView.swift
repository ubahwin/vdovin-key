import SwiftUI
import CodeScanner

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

                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 240, height: 240)
                            .blendMode(.destinationOut)
                    }
                )
        }
    }
}

#Preview {
    CameraView(viewModel: MainViewModel(coordinator: .init()))
        .environmentObject(Coordinator())
}
