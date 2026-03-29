import SwiftUI

struct ChatView: View {
    @State private var viewModel: ChatViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    // Support either trade or recipient context
    init(trade: Trade? = nil, recipient: User? = nil) {
        if let trade = trade {
            _viewModel = State(initialValue: ChatViewModel(trade: trade))
        } else if let recipient = recipient {
            _viewModel = State(initialValue: ChatViewModel(recipient: recipient))
        } else {
            // Default fallback for preview
            _viewModel = State(initialValue: ChatViewModel(recipient: User.sampleNeighbors.first!))
        }
    }

    private var partnerName: String {
        if let trade = viewModel.trade {
            let currentUserId = AuthService.shared.currentUserId ?? ""
            return trade.requester.id == currentUserId ? trade.provider.name : trade.requester.name
        }
        return viewModel.recipient?.name ?? "Neighbor"
    }

    private var headerTitle: String {
        if let trade = viewModel.trade {
            return trade.listing.title
        }
        return partnerName
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.accent)
                }
                
                AvatarView(name: partnerName, size: 36)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(headerTitle)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(viewModel.trade != nil ? "Trade Conversation" : "Direct Message")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let trade = viewModel.trade {
                    TradeStatusBadge(status: trade.status)
                } else {
                    Button(action: {}) {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)

            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if viewModel.messages.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.accent.opacity(0.3))
                                Text("No messages yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Start a conversation with \(partnerName)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 100)
                        } else {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(20)
                }
                .onChange(of: viewModel.messages.count) {
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Bar
            MessageInputBar(text: $appState.tempMessageDraft) {
                if !appState.tempMessageDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    viewModel.sendMessage(content: appState.tempMessageDraft)
                    appState.tempMessageDraft = ""
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
        .hideKeyboardWhenTappedAround()
    }
}

#Preview {
    ChatView(recipient: User.sampleNeighbors.first!)
        .environmentObject(AppState.shared)
}
