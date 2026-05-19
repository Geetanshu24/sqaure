import SwiftUI

struct PropBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let heightRatio: CGFloat
    @ViewBuilder let content: () -> Content

    @GestureState private var translation: CGFloat = 0

    private var dismissThreshold: CGFloat { 120 }

    var body: some View {
        GeometryReader { geometry in
            let sheetHeight = geometry.size.height * heightRatio

            ZStack(alignment: .bottom) {
                Color.black
                    .opacity(isPresented ? 0.5 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }

                if isPresented {
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 44, height: 5)
                            .padding(.top, 10)
                            .padding(.bottom, 12)

                        content()
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: sheetHeight, alignment: .top)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(
                        Color(uiColor: .systemBackground)
                    )
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 28,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 28,
                            style: .continuous
                        )
                    )
                    .offset(y: max(translation, 0))
                    .transition(.move(edge: .bottom))
                    .gesture(
                        DragGesture()
                            .updating($translation) { value, state, _ in
                                state = value.translation.height
                            }
                            .onEnded { value in
                                if value.translation.height > dismissThreshold {
                                    dismiss()
                                }
                            }
                    )
                }
            }
            .animation(.spring(response: 0.32, dampingFraction: 0.88), value: isPresented)
            .ignoresSafeArea()
            .allowsHitTesting(isPresented)
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
            isPresented = false
        }
    }
}
