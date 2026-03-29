import SwiftUI

struct TradeChatView: View {
    let trade: Trade
    @Bindable var viewModel: MessagesViewModel
    @State private var chatViewModel: ChatViewModel
    @State private var messageText: String = ""
    @State private var showCompleteConfirmation = false
    @State private var showCancelConfirmation = false

    init(trade: Trade, viewModel: MessagesViewModel) {
        self.trade = trade
        self._viewModel = Bindable(viewModel)
        self._chatViewModel = State(initialValue: ChatViewModel(trade: trade))
    }

    private var partnerName: String {
        let currentUserId = AuthService.shared.currentUserId ?? ""
        return trade.requester.id == currentUserId ? trade.provider.name : trade.requester.name
    }

    private var messages: [Message] {
        chatViewModel.messages
    }

    var body: some View {
        VStack(spacing: 0) {
            // Trade Status Banner
            TradeStatusBanner(trade: trade)

            // Chat Messages
            ScrollView {
                LazyVStack(spacing: AppTheme.spacingSM) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, AppTheme.spacingSM)
            }

            // Quick Actions (if trade is active)
            if trade.status == .active || trade.status == .pending {
                MessageInputBar(text: $messageText) {
                    let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    chatViewModel.sendMessage(content: trimmed)
                    messageText = ""
                }
            }
        }
        .navigationTitle(partnerName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
