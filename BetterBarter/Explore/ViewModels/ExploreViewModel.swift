import SwiftUI

@Observable
class ExploreViewModel {
    var searchText: String = ""
    var selectedCategory: Listing.Category = .all
    var selectedSegment: SegmentOption = .all
    var allListings: [Listing] = []
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
                    self.allListings = fetched.filter { !($0.isCompleted ?? false) }
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
                self.allListings = fetched.filter { !($0.isCompleted ?? false) }
            }
        } catch {
            print("DEBUG: Failed to refresh listings: \(error)")
        }
    }

    enum SegmentOption: String, CaseIterable {
        case all = "All"
        case offers = "Offers"
        case requests = "Requests"
    }

    var filteredListings: [Listing] {
        var results = allListings

        if selectedCategory != .all {
            results = results.filter { $0.category == selectedCategory }
        }

        switch selectedSegment {
        case .all: break
        case .offers: results = results.filter { $0.type == .offer }
        case .requests: results = results.filter { $0.type == .request }
        }

        if !searchText.isEmpty {
            results = results.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.ownerName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return results
    }

    var categories: [Listing.Category] {
        Listing.Category.allCases
    }
}
