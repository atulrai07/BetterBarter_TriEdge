import SwiftUI

@Observable
class HomeViewModel {
    var nearbyListings: [Listing] = []
    var isLoading: Bool = false
    
    init() {
        fetchListings()
    }
    
    func fetchListings() {
        isLoading = true
        Task {
            do {
                let fetched = try await FirebaseDataService.shared.getListings()
                await MainActor.run {
                    self.nearbyListings = fetched.filter { !($0.isCompleted ?? false) }
                    self.isLoading = false
                }
            } catch {
                print("DEBUG: Failed to fetch listings: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    func refresh() async {
        do {
            let fetched = try await FirebaseDataService.shared.getListings()
            await MainActor.run {
                self.nearbyListings = fetched.filter { !($0.isCompleted ?? false) }
            }
        } catch {
            print("DEBUG: Failed to refresh listings: \(error)")
        }
    }
    
    private var currentUser: User {
        AuthService.shared.currentUser ?? User.current
    }
    
    var creditBalance: Int { currentUser.credits }
    var trustScore: Double { currentUser.trustScore }
    var userName: String { currentUser.name }
    var userTier: AppTheme.TrustTier { currentUser.tier }

    var nearbyRequests: [Listing] {
        nearbyListings.filter { $0.type == .request }
    }

    var nearbyOffers: [Listing] {
        nearbyListings.filter { $0.type == .offer }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good Morning,"
        case 12..<17: return "Good Afternoon,"
        case 17..<21: return "Good Evening,"
        default: return "Good Night,"
        }
    }
}
