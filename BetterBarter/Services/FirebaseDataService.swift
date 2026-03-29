import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Combine

class FirebaseDataService: DataServiceProtocol {
    static let shared = FirebaseDataService()
    private lazy var db = Firestore.firestore()
    
    // MARK: - User Operations
    
    func getCurrentUser() async throws -> User {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "BetterBarter", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        return try await db.collection("users").document(uid).getDocument(as: User.self)
    }
    
    func getUser(id: String) async throws -> User {
        return try await db.collection("users").document(id).getDocument(as: User.self)
    }
    
    func updateUserName(userId: String, newName: String) async throws {
        try await db.collection("users").document(userId).updateData(["name": newName])
    }
    
    // MARK: - Listing Operations
    
    func getListings() async throws -> [Listing] {
        let snapshot = try await db.collection("listings")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Listing.self) }
    }
    
    func createListing(_ listing: Listing) async throws {
        try db.collection("listings").document(listing.id).setData(from: listing)
    }
    
    func deleteListing(_ listingId: String) async throws {
        try await db.collection("listings").document(listingId).delete()
    }
    
    func getListing(id: String) async throws -> Listing {
        return try await db.collection("listings").document(id).getDocument(as: Listing.self)
    }
    
    func uploadListingImage(_ imageData: Data, listingId: String) async throws -> String {
        let storageRef = Storage.storage().reference().child("listing_images/\(listingId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    // MARK: - Trade Operations
    
    func getTrade(id: String) async throws -> Trade {
        return try await db.collection("trades").document(id).getDocument(as: Trade.self)
    }
    
    func getTrades() async throws -> [Trade] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        // Fetch trades where user is either requester or provider
        let requesterSnapshot = try await db.collection("trades")
            .whereField("requester.id", isEqualTo: uid)
            .getDocuments()
            
        let providerSnapshot = try await db.collection("trades")
            .whereField("provider.id", isEqualTo: uid)
            .getDocuments()
            
        let requesterTrades = try requesterSnapshot.documents.compactMap { try $0.data(as: Trade.self) }
        let providerTrades = try providerSnapshot.documents.compactMap { try $0.data(as: Trade.self) }
        
        return (requesterTrades + providerTrades).sorted { $0.createdAt > $1.createdAt }
    }
    
    func createTrade(_ trade: Trade) async throws {
        try db.collection("trades").document(trade.id).setData(from: trade)
    }
    
    func updateTradeStatus(_ tradeID: String, status: Trade.TradeStatus) async throws {
        try await db.collection("trades").document(tradeID).updateData([
            "status": status.rawValue
        ])
    }
    
    func confirmTrade(_ tradeID: String, byUser userID: String) async throws {
        let tradeRef = db.collection("trades").document(tradeID)
        let dbRef = self.db
        
        let _: Any? = try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let tradeDoc: DocumentSnapshot
            do {
                tradeDoc = try transaction.getDocument(tradeRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            
            guard var trade = try? tradeDoc.data(as: Trade.self) else { return nil }
            
            let isProvider = trade.provider.id == userID
            var partnerAlreadyConfirmed = false
            
            if isProvider {
                partnerAlreadyConfirmed = (trade.status == .requesterConfirmed)
                trade.status = partnerAlreadyConfirmed ? .completed : .providerConfirmed
            } else {
                partnerAlreadyConfirmed = (trade.status == .providerConfirmed)
                trade.status = partnerAlreadyConfirmed ? .completed : .requesterConfirmed
            }
            
            if partnerAlreadyConfirmed {
                trade.completedAt = Date()
                let listingRef = dbRef.collection("listings").document(trade.listing.id)
                transaction.updateData(["isCompleted": true], forDocument: listingRef)
                
                // 1. Transfer credits: Deduct from requester, add to provider.
                let credits = Int64(trade.listing.credits)
                let providerRef = dbRef.collection("users").document(trade.provider.id)
                let requesterRef = dbRef.collection("users").document(trade.requester.id)
                
                transaction.updateData(["credits": FieldValue.increment(credits)], forDocument: providerRef)
                transaction.updateData(["credits": FieldValue.increment(-credits)], forDocument: requesterRef)
            }
            
            do {
                try transaction.setData(from: trade, forDocument: tradeRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
            }
            return nil
        }
        
        // After transaction succeeds, update trust scores for both users
        // This is done outside the transaction to avoid complex reads inside write blocks
        let tradeSnap = try await tradeRef.getDocument()
        if let trade = try? tradeSnap.data(as: Trade.self), trade.status == .completed {
            Task {
                try? await self.recalculateTrustScore(userId: trade.provider.id)
                try? await self.recalculateTrustScore(userId: trade.requester.id)
            }
        }
    }
    
    func recalculateTrustScore(userId: String) async throws {
        // Fetch all reviews
        let reviews = try await getReviews(for: userId)
        
        // Fetch ALL trades for accurate completion/cancellation rates
        let tradesSnap = try await db.collection("trades").getDocuments()
        let allTrades = tradesSnap.documents.compactMap { try? $0.data(as: Trade.self) }
            .filter { $0.provider.id == userId || $0.requester.id == userId }
        
        let completedTrades = allTrades.filter { $0.status == .completed }.count
        let cancelledTrades = allTrades.filter { $0.status == .cancelled }.count
        let totalTradesCount = allTrades.count
        
        let completionRate: Double
        let cancelRate: Double
        
        if totalTradesCount == 0 {
            completionRate = 1.0 // 100% completion rate for new users
            cancelRate = 0.0
        } else {
            completionRate = Double(completedTrades) / Double(totalTradesCount)
            cancelRate = Double(cancelledTrades) / Double(totalTradesCount)
        }
        
        let avgRating = reviews.isEmpty ? 5.0 : Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
        
        // Trust Score Rule:
        // (Completion Rate × 50%) + (Average Rating × 30%) - (Cancellation Penalty × 20%)
        let completionPoints = (completionRate * 100.0) * 0.50
        let ratingPoints = (avgRating / 5.0 * 100.0) * 0.30
        let cancellationPenalty = (cancelRate * 100.0) * 0.20
        
        // Add 20 base points so that a perfect user gets 100% (50 + 30 + 20)
        let exactScore = 20.0 + completionPoints + ratingPoints - cancellationPenalty
        let newTrustScore = min(100.0, max(0.0, exactScore))
        
        try await updateTrustScore(userId: userId, newScore: newTrustScore)
    }
    
    // MARK: - Message Operations
    
    /// Generates a deterministic chat ID for two users by sorting their IDs alphabetically.
    func getChatId(user1: String, user2: String) -> String {
        let ids = [user1, user2].sorted()
        return "\(ids[0])_\(ids[1])"
    }
    
    func getMessages(for chatId: String) async throws -> [Message] {
        let snapshot = try await db.collection("messages").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .getDocuments()
        let currentUserId = Auth.auth().currentUser?.uid
        return snapshot.documents.compactMap { doc -> Message? in
            guard var msg = try? doc.data(as: Message.self) else { return nil }
            msg.isFromCurrentUser = (msg.senderID == currentUserId)
            return msg
        }
    }
    
    func sendMessage(chatId: String, message: Message) async throws {
        try db.collection("messages").document(chatId).collection("messages").addDocument(from: message)
    }
    
    // MARK: - Real-time Listeners
    
    func listenForMessages(chatId: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        let currentUserId = Auth.auth().currentUser?.uid
        return db.collection("messages").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap { doc -> Message? in
                    guard var msg = try? doc.data(as: Message.self) else { return nil }
                    msg.isFromCurrentUser = (msg.senderID == currentUserId)
                    return msg
                }
                completion(messages)
            }
    }
    
    // MARK: - Review and Trust Score
    
    func createReview(_ review: Review) async throws {
        try db.collection("reviews").document(review.id).setData(from: review)
    }
    
    func getReviews(for userId: String) async throws -> [Review] {
        let snapshot = try await db.collection("reviews")
            .whereField("receiverId", isEqualTo: userId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Review.self) }
    }
    
    func getReviewsForTrade(tradeId: String) async throws -> [Review] {
        let snapshot = try await db.collection("reviews")
            .whereField("tradeId", isEqualTo: tradeId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Review.self) }
    }
    
    func updateTrustScore(userId: String, newScore: Double) async throws {
        try await db.collection("users").document(userId).updateData([
            "trustScore": newScore
        ])
    }
    
    // MARK: - Notifications
    
    func createNotification(_ notification: AppNotification) async throws {
        try db.collection("notifications").document(notification.id).setData(from: notification)
    }
    
    func getNotifications(userId: String) async throws -> [AppNotification] {
        let snapshot = try await db.collection("notifications")
            .whereField("recipientId", isEqualTo: userId)
            .getDocuments()
        let notifications = snapshot.documents.compactMap { try? $0.data(as: AppNotification.self) }
        // Sort client-side to avoid index requirement
        return notifications.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    func listenForNotifications(userId: String, completion: @escaping ([AppNotification]) -> Void) -> ListenerRegistration {
        return db.collection("notifications")
            .whereField("recipientId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening for notifications: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let notifications = documents.compactMap { try? $0.data(as: AppNotification.self) }
                // Sort client-side to avoid index requirement
                let sorted = notifications.sorted(by: { $0.createdAt > $1.createdAt })
                completion(sorted)
            }
    }
    
    func markNotificationRead(id: String) async throws {
        try await db.collection("notifications").document(id).updateData([
            "isRead": true
        ])
    }
}
