import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    @State private var offsetY: CGFloat = 0
    @State private var isExpanded = false

    let fullHeight: CGFloat = UIScreen.main.bounds.height
    let expandedOffset: CGFloat = 330

    var body: some View {
        ZStack {
            AccountView(viewModel: viewModel)

            CameraView(viewModel: viewModel)
                .ignoresSafeArea()
                .shadow(radius: 10)
                .overlay {
                    VStack(spacing: .zero) {
                        HStack(spacing: .zero) {
                            Spacer()

                            Button {
                                switchAccount(toOpen: !isExpanded)
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(.black.opacity(0.3))
                                        .frame(width: 56, height: 56)

                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical)
                        }
                        Spacer()
                    }
                }
                .offset(y: offsetY)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if abs(value.velocity.height) > 3000, offsetY != 0 {
                                return
                            }

                            let newOffset = value.translation.height + (isExpanded ? expandedOffset : 0)

                            guard
                                newOffset < expandedOffset,
                                newOffset > 0
                            else {
                                return
                            }

                            offsetY = newOffset
                        }
                        .onEnded { value in
                            if abs(value.velocity.height) > 3000 {
                                switchAccount(toOpen: false)
                                return
                            }

                            switchAccount(toOpen: value.translation.height > 50)
                        }
                )
                .sensoryFeedback(.impact(weight: .heavy, intensity: 0.9), trigger: isExpanded)
        }
    }

    private func switchAccount(toOpen: Bool) {
        withAnimation(.spring(duration: 0.2)) {
            isExpanded = toOpen
            offsetY = toOpen ? expandedOffset : 0
        }
    }
}

#Preview {
    MainView(viewModel: MainViewModel(coordinator: Coordinator()))
        .environmentObject(Coordinator())
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
