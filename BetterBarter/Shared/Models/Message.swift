import Foundation

struct Message: Identifiable, Hashable, Codable {
    let id: String
    var tradeID: String?
    var recipientID: String?
    var senderID: String
    var senderName: String
    var content: String
    var timestamp: Date
    var isFromCurrentUser: Bool
}

// MARK: - Sample Data

extension Message {
    static func samplesForTrade(_ tradeID: String) -> [Message] {
        let currentUserID = User.current.id
        let partnerID = "user_partner"

        return [
            Message(id: "msg_1", tradeID: tradeID, recipientID: currentUserID, senderID: partnerID,
                        senderName: "Partner", content: "Hi! I saw your listing. Is this still available?",
                        timestamp: .now.addingTimeInterval(-7200), isFromCurrentUser: false),

            Message(id: "msg_2", tradeID: tradeID, recipientID: partnerID, senderID: currentUserID,
                        senderName: "You", content: "Yes, absolutely! When would work for you?",
                        timestamp: .now.addingTimeInterval(-6800), isFromCurrentUser: true),

            Message(id: "msg_3", tradeID: tradeID, recipientID: currentUserID, senderID: partnerID,
                        senderName: "Partner", content: "How about tomorrow evening around 5 PM?",
                        timestamp: .now.addingTimeInterval(-6400), isFromCurrentUser: false),

            Message(id: "msg_4", tradeID: tradeID, recipientID: partnerID, senderID: currentUserID,
                        senderName: "You", content: "That works perfectly. See you then! 👍",
                        timestamp: .now.addingTimeInterval(-6000), isFromCurrentUser: true),

            Message(id: "msg_5", tradeID: tradeID, recipientID: currentUserID, senderID: partnerID,
                        senderName: "Partner", content: "Great, looking forward to it!",
                        timestamp: .now.addingTimeInterval(-5600), isFromCurrentUser: false),
        ]
    }
}
