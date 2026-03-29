import Foundation
import Observation
import FirebaseFirestore

@Observable
class ActiveTradeViewModel {
    var trade: Trade
    var tradeReviews: [Review] = []
    private var listener: ListenerRegistration?
    private var db: Firestore { Firestore.firestore() }
    
    var isProvider: Bool {
        trade.provider.id == AuthService.shared.currentUserId
    }
    
    var hasConfirmed: Bool {
        (isProvider && trade.status == .providerConfirmed) || (!isProvider && trade.status == .requesterConfirmed)
    }
    
    var otherConfirmed: Bool {
        (isProvider && trade.status == .requesterConfirmed) || (!isProvider && trade.status == .providerConfirmed)
    }
    
    init(trade: Trade) {
        self.trade = trade
        setupListener()
        fetchReviews()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func setupListener() {
        listener = db.collection("trades").document(trade.id).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self,
                  let data = try? snapshot?.data(as: Trade.self) else { return }
            
            DispatchQueue.main.async {
                self.trade = data
                if data.status == .completed && self.tradeReviews.isEmpty {
                    self.fetchReviews()
                }
            }
        }
    }
    
    func fetchReviews() {
        Task {
            do {
                let fetched = try await FirebaseDataService.shared.getReviewsForTrade(tradeId: trade.id)
                await MainActor.run {
                    self.tradeReviews = fetched
                }
            } catch {
                print("DEBUG: Failed to fetch trade reviews: \(error)")
            }
        }
    }
    
    func confirmService() {
        guard let currentUserId = AuthService.shared.currentUserId else { return }
        Task {
            try? await FirebaseDataService.shared.confirmTrade(trade.id, byUser: currentUserId)
        }
    }
    
    func cancelTrade() {
        Task {
            try? await FirebaseDataService.shared.updateTradeStatus(trade.id, status: .cancelled)
        }
    }
}
