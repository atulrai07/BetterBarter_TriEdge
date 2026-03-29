import Foundation
import Observation
import FirebaseFirestore

@Observable
class ChatViewModel {
    var messages: [Message] = []
    let trade: Trade?
    let recipient: User?
    private var listener: ListenerRegistration?
    private let chatId: String
    
    // Initializer for trade-based chat
    init(trade: Trade) {
        self.trade = trade
        self.recipient = nil
        self.chatId = trade.id // Using trade ID as the chat ID for trade context
        setupListener()
    }
    
    // Initializer for direct profile-to-profile chat
    init(recipient: User) {
        self.trade = nil
        self.recipient = recipient
        
        // Use deterministic chat ID for direct messages
        if let currentUserId = AuthService.shared.currentUserId {
            self.chatId = FirebaseDataService.shared.getChatId(user1: currentUserId, user2: recipient.id)
        } else {
            self.chatId = "temp_\(UUID().uuidString)"
        }
        
        setupListener()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func setupListener() {
        listener = FirebaseDataService.shared.listenForMessages(chatId: chatId) { [weak self] newMessages in
            DispatchQueue.main.async {
                self?.messages = newMessages
            }
        }
    }
    
    func sendMessage(content: String) {
        guard let currentUserId = AuthService.shared.currentUserId,
              let currentUser = AuthService.shared.currentUser else { return }
              
        let recipientID: String
        if let trade = trade {
            recipientID = (trade.requester.id == currentUserId) ? trade.provider.id : trade.requester.id
        } else {
            recipientID = recipient?.id ?? "unknown_user"
        }
        let messageId = "msg_\(UUID().uuidString)"
        
        let newMessage = Message(
            id: messageId,
            tradeID: trade?.id,
            recipientID: recipientID,
            senderID: currentUserId,
            senderName: currentUser.name,
            content: content,
            timestamp: Date(),
            isFromCurrentUser: true
        )
        
        Task {
            try? await FirebaseDataService.shared.sendMessage(chatId: chatId, message: newMessage)
        }
    }
}
