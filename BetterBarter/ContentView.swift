import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var messagesPath = NavigationPath()
    @State private var viewModel = MessagesViewModel() // Reuse for deep link lookup
    
    enum TabSelection: String, CaseIterable {
        case home = "Home"
        case explore = "Explore"
        case messages = "Messages"
        case create = "Post"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .explore: return "safari.fill"
            case .messages: return "bubble.left.and.bubble.right.fill"
            case .create: return "plus.circle.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $appState.activeTab) {
            Tab("Home", systemImage: TabSelection.home.icon, value: .home) {
                HomeView()
            }
            Tab("Explore", systemImage: TabSelection.explore.icon, value: .explore) {
                ExploreView()
            }
            Tab("Messages", systemImage: TabSelection.messages.icon, value: .messages) {
                MessagesView(navigationPath: $messagesPath)
            }
            Tab("Post", systemImage: TabSelection.create.icon, value: .create, role: .search) {
                CreatePostView(selectedTab: $appState.activeTab)
            }
        }
        .tint(AppTheme.accent)
        .onChange(of: appState.focusedTradeId) {
            handleDeepLink()
        }
    }
    
    private func handleDeepLink() {
        guard let tradeId = appState.focusedTradeId else { return }
        
        // Ensure we are on messages tab
        appState.activeTab = .messages
        
        // Look up trade or channel
        if let trade = viewModel.trades.first(where: { $0.id == tradeId }) {
            messagesPath.append(trade)
            appState.focusedTradeId = nil
        } else if let channel = viewModel.channels.first(where: { $0.id == tradeId }) {
            messagesPath.append(channel)
            appState.focusedTradeId = nil
        } else {
            // If not loaded yet, fetch and retry
            viewModel.fetchAllCommunication()
            // We'll trust the MessagesView's onAppear or internal logic to handle it once loaded
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}

