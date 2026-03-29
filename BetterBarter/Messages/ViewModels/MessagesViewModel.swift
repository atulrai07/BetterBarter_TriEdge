import Foundation
import Observation

@Observable
class MessagesViewModel {
    var trades: [Trade] = []
    var channels: [ChatChannel] = []
    var messages: [String: [Message]] = [:]
    var isLoading: Bool = false

    init() {
        fetchAllCommunication()
    }

    func fetchAllCommunication() {
        isLoading = true
        Task {
            // Fetch both in parallel
            async let fetchedTrades = FirebaseDataService.shared.getTrades()
            async let fetchedChannels = FirebaseDataService.shared.getChatChannels()
            
            do {
                let (t, c) = try await (fetchedTrades, fetchedChannels)
                await MainActor.run {
                    self.trades = t
                    self.channels = c
                    self.isLoading = false
                    
                    // Fetch context for trades
                    for trade in t { self.fetchLastMessage(for: trade.id) }
                    // Channels already have last message in metadata, but we can refresh
                    for channel in c { self.fetchLastMessage(for: channel.id) }
                }
            } catch {
                print("DEBUG: Failed to fetch communication: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }

    private func fetchLastMessage(for id: String) {
        Task {
            do {
                let chatMessages = try await FirebaseDataService.shared.getMessages(for: id)
                await MainActor.run {
                    self.messages[id] = chatMessages
                }
            } catch {
                print("DEBUG: Failed to fetch messages for \(id): \(error)")
            }
        }
    }

    var activeTrades: [Trade] {
        trades.filter { $0.status == .active || $0.status == .pending }
    }

    var completedTrades: [Trade] {
        trades.filter { $0.status == .completed }
    }

    func lastMessage(for trade: Trade) -> Message? {
        lastMessage(for: trade.id)
    }

    func lastMessage(for id: String) -> Message? {
        messages[id]?.last
    }

    func sendMessage(_ content: String, for trade: Trade) {
        guard let currentUserId = AuthService.shared.currentUserId,
              let currentUser = AuthService.shared.currentUser else { return }
              
        let recipientID = trade.requester.id == currentUserId ? trade.provider.id : trade.requester.id
        let messageId = "msg_\(UUID().uuidString)"
        let message = Message(
            id: messageId,
            tradeID: trade.id,
            recipientID: recipientID,
            senderID: currentUserId,
            senderName: currentUser.name,
            content: content,
            timestamp: .now,
            isFromCurrentUser: true
        )
        
        Task {
            try? await FirebaseDataService.shared.sendMessage(chatId: trade.id, message: message)
            await MainActor.run {
                self.messages[trade.id, default: []].append(message)
            }
        }
    }

    func completeTrade(_ trade: Trade) {
        Task {
            try? await FirebaseDataService.shared.updateTradeStatus(trade.id, status: .completed)
            fetchAllCommunication()
        }
    }

    func cancelTrade(_ trade: Trade) {
        Task {
            try? await FirebaseDataService.shared.updateTradeStatus(trade.id, status: .cancelled)
            fetchAllCommunication()
        }
    }
}
