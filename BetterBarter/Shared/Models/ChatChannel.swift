import Foundation

struct ChatChannel: Identifiable, Codable, Hashable {
    let id: String
    let participantIds: [String]
    let participantNames: [String: String]
    let participantAvatars: [String: String]
    var lastMessage: String
    var lastMessageSenderId: String
    var timestamp: Date
    
    // Helper to get the other participant in a 1-to-1 chat
    func getPartnerId(currentUserId: String) -> String {
        participantIds.first { $0 != currentUserId } ?? currentUserId
    }
    
    func getPartnerName(currentUserId: String) -> String {
        let partnerId = getPartnerId(currentUserId: currentUserId)
        return participantNames[partnerId] ?? "Unknown Neighbor"
    }
    
    func getPartnerAvatar(currentUserId: String) -> String {
        let partnerId = getPartnerId(currentUserId: currentUserId)
        return participantAvatars[partnerId] ?? "person.circle.fill"
    }
}
