import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background color matching Home Screen top card
            Color(red: 24/255, green: 164/255, blue: 160/255)
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Logo image
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(isAnimating ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isAnimating)


                // App name
                Text("Better Barter")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .tracking(0.5)
            }
        }
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    appState.isShowingSplash = false
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
        .environmentObject(AppState.shared)
}
