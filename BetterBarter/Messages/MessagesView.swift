import SwiftUI

struct MessagesView: View {
    @State private var viewModel = MessagesViewModel()

    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    // Active & Pending Trades
                    if !viewModel.activeTrades.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            SectionHeader(title: "Active")
                                .padding(.horizontal)

                            LazyVStack(spacing: AppTheme.spacingSM) {
                                ForEach(viewModel.activeTrades) { trade in
                                    NavigationLink {
                                        TradeChatView(trade: trade, viewModel: viewModel)
                                    } label: {
                                        ConversationRow(
                                            trade: trade,
                                            lastMessage: viewModel.lastMessage(for: trade)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Completed Trades
                    if !viewModel.completedTrades.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            SectionHeader(title: "Completed")
                                .padding(.horizontal)

                            LazyVStack(spacing: AppTheme.spacingSM) {
                                ForEach(viewModel.completedTrades) { trade in
                                    NavigationLink {
                                        TradeChatView(trade: trade, viewModel: viewModel)
                                    } label: {
                                        ConversationRow(
                                            trade: trade,
                                            lastMessage: viewModel.lastMessage(for: trade)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Direct Messages
                    if !viewModel.channels.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            SectionHeader(title: "Direct Messages")
                                .padding(.horizontal)

                            LazyVStack(spacing: AppTheme.spacingSM) {
                                ForEach(viewModel.channels) { channel in
                                    NavigationLink {
                                        ChatView(recipient: User(
                                            id: channel.getPartnerId(currentUserId: AuthService.shared.currentUserId ?? ""),
                                            name: channel.getPartnerName(currentUserId: AuthService.shared.currentUserId ?? ""),
                                            avatarName: channel.getPartnerAvatar(currentUserId: AuthService.shared.currentUserId ?? ""),
                                            location: "",
                                            trustScore: 0,
                                            credits: 0,
                                            skills: [],
                                            interests: [],
                                            joinDate: Date()
                                        ))
                                    } label: {
                                        DirectMessageRow(
                                            channel: channel,
                                            lastMessage: viewModel.lastMessage(for: channel.id)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    if viewModel.activeTrades.isEmpty && viewModel.completedTrades.isEmpty && viewModel.channels.isEmpty {
                        ContentUnavailableView(
                            "No Conversations",
                            systemImage: "bubble.left.and.bubble.right",
                            description: Text("Start a trade or message a neighbor to begin a conversation.")
                        )
                        .padding(.top, 60)
                    }
                }
                .padding(.top, AppTheme.spacingSM)
            }
            .navigationDestination(for: Trade.self) { trade in
                ChatView(trade: trade)
            }
            .navigationDestination(for: ChatChannel.self) { channel in
                ChatView(recipient: User(
                    id: channel.getPartnerId(currentUserId: AuthService.shared.currentUserId ?? ""),
                    name: channel.getPartnerName(currentUserId: AuthService.shared.currentUserId ?? ""),
                    avatarName: channel.getPartnerAvatar(currentUserId: AuthService.shared.currentUserId ?? ""),
                    location: "", trustScore: 0, credits: 0, skills: [], interests: [], joinDate: Date()
                ))
            }
            .refreshable {
                viewModel.fetchAllCommunication()
            }
            .onAppear {
                viewModel.fetchAllCommunication()
            }
            .background(AppTheme.background)
            .navigationTitle("Messages")
        }
    }
}

#Preview {
    MessagesView(navigationPath: .constant(NavigationPath()))
        .environmentObject(AppState.shared)
}
