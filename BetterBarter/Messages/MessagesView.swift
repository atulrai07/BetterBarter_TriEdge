import SwiftUI

struct MessagesView: View {
    @State private var viewModel = MessagesViewModel()

    var body: some View {
        NavigationStack {
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

                    if viewModel.activeTrades.isEmpty && viewModel.completedTrades.isEmpty {
                        ContentUnavailableView(
                            "No Conversations",
                            systemImage: "bubble.left.and.bubble.right",
                            description: Text("Start a trade from Home or Explore to begin a conversation.")
                        )
                        .padding(.top, 60)
                    }
                }
                .padding(.top, AppTheme.spacingSM)
            }
            .refreshable {
                viewModel.fetchTrades()
            }
            .background(AppTheme.background)
            .navigationTitle("Messages")
        }
    }
}

#Preview {
    MessagesView()
}
