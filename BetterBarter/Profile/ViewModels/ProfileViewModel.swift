import SwiftUI

@Observable
class ProfileViewModel {
    private var _internalUser: User
    private let isCurrentUser: Bool
    var reviews: [Review] = []
    var activeListings: [Listing] = []
    var isLoading: Bool = false

    init(user: User? = nil) {
        let initialUser = user ?? AuthService.shared.currentUser ?? User.current
        self._internalUser = initialUser
        self.isCurrentUser = (user == nil || user?.id == AuthService.shared.currentUserId)
        self.activeListings = []
        self.reviews = []
        self.isLoading = false
        
        fetchUserData()
        fetchActiveListings()
        fetchReviews()
    }
    
    var user: User {
        if isCurrentUser, let authUser = AuthService.shared.currentUser {
            return authUser
        }
        return _internalUser
    }
    
    func fetchUserData() {
        Task {
            do {
                let updatedUser = try await FirebaseDataService.shared.getUser(id: _internalUser.id)
                await MainActor.run {
                    self._internalUser = updatedUser
                }
            } catch {
                print("DEBUG: Failed to refresh user data: \(error)")
            }
        }
    }
    
    func fetchActiveListings() {
        isLoading = true
        Task {
            do {
                let fetched = try await FirebaseDataService.shared.getListings()
                await MainActor.run {
                    self.activeListings = fetched.filter { $0.ownerID == self.user.id }
                    self.isLoading = false
                }
            } catch {
                print("DEBUG: Failed to fetch user listings: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }

    func fetchReviews() {
        Task {
            do {
                let fetchedReviews = try await FirebaseDataService.shared.getReviews(for: user.id)
                await MainActor.run {
                    self.reviews = fetchedReviews.sorted { $0.date > $1.date }
                }
            } catch {
                print("DEBUG: Failed to fetch reviews: \(error)")
            }
        }
    }

    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        return Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
    }

    var settingsItems: [(String, String)] = [
        ("bell.badge", "Notifications"),
        ("lock.shield", "Privacy & Safety"),
        ("questionmark.circle", "Help & Support"),
        ("info.circle", "About"),
    ]
    
    func updateName(_ newName: String) {
        let cleanName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        
        if isCurrentUser {
             // AuthService update will trigger UI via the reactive 'user' property
        } else {
             self._internalUser.name = cleanName
        }
        
        Task {
            do {
                try await FirebaseDataService.shared.updateUserName(userId: user.id, newName: cleanName)
            } catch {
                print("DEBUG: Failed to update username: \(error)")
            }
        }
    }
}
