import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isShowingSplash: Bool = true
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @Published var isTabBarHidden: Bool = false
    @Published var activeTab: ContentView.TabSelection = .home
    @Published var focusedListingId: String? = nil
    @Published var focusedTradeId: String? = nil
    
    static let shared = AppState()
}
