import SwiftUI
import CoreLocation
import Combine
import FirebaseFirestore

@Observable
class HomeViewModel {
    var nearbyListings: [Listing] = []
    var isLoading: Bool = false
    var hiddenListingIDs: Set<String> = []
    var userLocation: CLLocation?
    var unreadNotificationsCount: Int = 0
    
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    private var notificationListener: ListenerRegistration?
    
    init() {
        setupLocationUpdates()
        fetchListings()
        setupNotificationListener()
    }
    
    deinit {
        notificationListener?.remove()
    }
    
    private func setupNotificationListener() {
        guard let currentUserId = AuthService.shared.currentUser?.id else { return }
        
        notificationListener = FirebaseDataService.shared.listenForNotifications(userId: currentUserId) { [weak self] notifications in
            DispatchQueue.main.async {
                self?.unreadNotificationsCount = notifications.filter { !$0.isRead }.count
            }
        }
    }
    
    private func setupLocationUpdates() {
        locationManager.$location
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.userLocation = location
            }
            .store(in: &cancellables)
        
        // Request initial location
        locationManager.requestLocation()
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
    
    func removeListing(_ listing: Listing) {
        Task {
            do {
                try await FirebaseDataService.shared.deleteListing(listing.id)
                await MainActor.run {
                    self.nearbyListings.removeAll { $0.id == listing.id }
                }
            } catch {
                print("DEBUG: Failed to delete listing: \(error)")
                // If delete fails on server, still hide it locally
                await MainActor.run {
                    self.hiddenListingIDs.insert(listing.id)
                }
            }
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
        let filtered = nearbyListings.filter { $0.type == .request && !hiddenListingIDs.contains($0.id) }
        print("DEBUG: nearbyRequests count: \(filtered.count), titles: \(filtered.map { "\($0.title) (type: \($0.type.rawValue))" })")
        return filtered
    }

    var nearbyOffers: [Listing] {
        let filtered = nearbyListings.filter { $0.type == .offer && !hiddenListingIDs.contains($0.id) }
        print("DEBUG: nearbyOffers count: \(filtered.count), titles: \(filtered.map { "\($0.title) (type: \($0.type.rawValue))" })")
        return filtered
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
