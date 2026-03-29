import Foundation
import Combine

/// A protocol defining the data operations needed for BetterBarter.
/// This abstracts the backend implementation, allowing us to swap
/// Firebase, Supabase, or a Mock service easily.
protocol DataServiceProtocol {
    // User operations
    func getCurrentUser() async throws -> User
    func getUser(id: String) async throws -> User
    
    // Listing operations
    func getListings() async throws -> [Listing]
    func createListing(_ listing: Listing) async throws
    
    // Trade operations
    func getTrades() async throws -> [Trade]
    func createTrade(_ trade: Trade) async throws
    func updateTradeStatus(_ tradeID: String, status: Trade.TradeStatus) async throws
    func confirmTrade(_ tradeID: String, byUser userID: String) async throws
    
    // Message operations
    func getChatId(user1: String, user2: String) -> String
    func getMessages(for chatId: String) async throws -> [Message]
    func sendMessage(chatId: String, message: Message) async throws
    
    // Review and Trust Score
    func createReview(_ review: Review) async throws
    func updateTrustScore(userId: String, newScore: Double) async throws
}

/// A mock implementation of the DataService using static sample data.
class MockDataService: DataServiceProtocol {
    static let shared = MockDataService()
    
    func getCurrentUser() async throws -> User {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        return User.current
    }
    
    func getUser(id: String) async throws -> User {
        if id == User.current.id { return User.current }
        return User.sampleNeighbors.first(where: { $0.id == id }) ?? User.current
    }
    
    func getListings() async throws -> [Listing] {
        try? await Task.sleep(nanoseconds: 800_000_000)
        return Listing.samples
    }
    
    func createListing(_ listing: Listing) async throws {
        // Mock implementation
    }
    
    func getTrades() async throws -> [Trade] {
        return Trade.samples
    }
    
    func createTrade(_ trade: Trade) async throws {
        // Mock implementation
    }
    
    func updateTradeStatus(_ tradeID: String, status: Trade.TradeStatus) async throws {
        // Mock implementation
    }
    
    func confirmTrade(_ tradeID: String, byUser userID: String) async throws {
        // Mock implementation
        print("MOCK: Confirming trade \(tradeID) by user \(userID)")
    }
    
    func getChatId(user1: String, user2: String) -> String {
        let ids = [user1, user2].sorted()
        return "\(ids[0])_\(ids[1])"
    }
    
    func getMessages(for chatId: String) async throws -> [Message] {
        return Message.samplesForTrade(chatId)
    }
    
    func sendMessage(chatId: String, message: Message) async throws {
        // Mock implementation
    }
    
    func createReview(_ review: Review) async throws {
        // Mock implementation
    }
    
    func updateTrustScore(userId: String, newScore: Double) async throws {
        // Mock implementation
    }
}
