import Foundation
import Observation

@Observable
class MessagesViewModel {
    var trades: [Trade] = []
    var messages: [String: [Message]] = [:]
    var isLoading: Bool = false

    init() {
        fetchTrades()
    }

    func fetchTrades() {
        isLoading = true
        Task {
            do {
                let fetchedTrades = try await FirebaseDataService.shared.getTrades()
                await MainActor.run {
                    self.trades = fetchedTrades
                    self.isLoading = false
                    
                    // Fetch last message for each trade to provide inbox context
                    for trade in fetchedTrades {
                        self.fetchLastMessage(for: trade)
                    }
                }
            } catch {
                print("DEBUG: Failed to fetch trades: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }

    private func fetchLastMessage(for trade: Trade) {
        Task {
            do {
                let tradeMessages = try await FirebaseDataService.shared.getMessages(for: trade.id)
                await MainActor.run {
                    self.messages[trade.id] = tradeMessages
                }
            } catch {
                print("DEBUG: Failed to fetch messages for trade \(trade.id): \(error)")
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
        messages[trade.id]?.last
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
            fetchTrades()
        }
    }

    func cancelTrade(_ trade: Trade) {
        Task {
            try? await FirebaseDataService.shared.updateTradeStatus(trade.id, status: .cancelled)
            fetchTrades()
        }
    }
}
