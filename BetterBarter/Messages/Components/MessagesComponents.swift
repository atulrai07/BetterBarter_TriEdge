import SwiftUI

// MARK: - Conversation Row

struct ConversationRow: View {
    let trade: Trade
    let lastMessage: Message?

    private var partnerName: String {
        trade.requester.id == User.current.id ? trade.provider.name : trade.requester.name
    }

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            AvatarView(name: partnerName, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(partnerName)
                        .font(.headline)

                    Spacer()

                    if let lastMessage = lastMessage {
                        Text(lastMessage.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                HStack {
                    Text(trade.listing.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer()

                    TradeStatusBadge(status: trade.status)
                }

                if let lastMessage = lastMessage {
                    Text(lastMessage.content)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .cardStyle()
    }
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(message.isFromCurrentUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromCurrentUser
                        ? AnyShapeStyle(AppTheme.accent)
                        : AnyShapeStyle(Color(.tertiarySystemGroupedBackground))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !message.isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Message Input Bar

struct MessageInputBar: View {
    @Binding var text: String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Type a message")
                        .font(.body)
                        .foregroundStyle(.secondary.opacity(0.6))
                        .padding(.leading, 14)
                }
                
                TextField("", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            Button {
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onSend()
                } else {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            } label: {
                Image(systemName: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                      ? "xmark.circle.fill" : "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                    ? Color.gray : AppTheme.accent)
                    .contentTransition(.symbolEffect(.replace))
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: text.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Trade Status Banner

struct TradeStatusBanner: View {
    let trade: Trade

    var body: some View {
        HStack {
            Image(systemName: trade.listing.iconName)
                .foregroundStyle(AppTheme.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(trade.listing.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                CreditIndicator(amount: trade.listing.credits)
            }

            Spacer()

            TradeStatusBadge(status: trade.status)
        }
        .padding(AppTheme.spacingMD)
        .background(AppTheme.cardBackground)
    }
}
