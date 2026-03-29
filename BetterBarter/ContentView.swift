import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

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
                MessagesView()
            }
            Tab("Post", systemImage: TabSelection.create.icon, value: .create, role: .search) {
                CreatePostView(selectedTab: $appState.activeTab)
            }
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}

