import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @Environment(AuthService.self) private var authService
    
    var body: some View {
        Group {
            if appState.isShowingSplash {
                SplashScreen()
                    .transition(.opacity)
            } else if authService.isLoading {
                LoadingView()
                    .transition(.opacity)
            } else if authService.isAuthenticated {
                ContentView()
                    .transition(.opacity)
            } else if !appState.hasSeenOnboarding {
                OnboardingView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .opacity
                    ))
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.isShowingSplash)
        .animation(.easeInOut(duration: 0.35), value: appState.hasSeenOnboarding)
        .animation(.easeInOut(duration: 0.35), value: authService.isLoading)
        .animation(.easeInOut(duration: 0.35), value: authService.isAuthenticated)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Connecting to BetterBarter...")
                .font(.headline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.secondaryBackground)
    }
}
