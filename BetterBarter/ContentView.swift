import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var previousTab: Tab = .home
    @State private var showCreatePost = false

    enum Tab: String, CaseIterable {
        case home = "Home"
        case explore = "Explore"
        case create = "Post"
        case messages = "Messages"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .explore: return "safari.fill"
            case .create: return "plus.circle.fill"
            case .messages: return "bubble.left.and.bubble.right.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .home:
                        HomeView()
                    case .explore:
                        ExploreView()
                    case .create:
                        Color.clear
                    case .messages:
                        MessagesView()
                    case .profile:
                        ProfileView()
                    }
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
        .tint(AppTheme.accent)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .create {
                showCreatePost = true
                selectedTab = oldValue
            } else {
                previousTab = newValue
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}

