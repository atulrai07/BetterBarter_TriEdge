import Foundation

struct AppNotification: Identifiable, Codable {
    let id: String
    let recipientId: String
    let senderId: String
    let senderName: String
    let listingId: String
    let listingTitle: String
    let tradeId: String
    var isRead: Bool
    let createdAt: Date
    
    // Add type if future notifications need distinction
    enum NotificationType: String, Codable {
        case tradeRequest
    }
    let type: NotificationType
}
