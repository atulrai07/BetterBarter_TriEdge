import SwiftUI

struct NearbyListingsView: View {
    let title: String
    let listings: [Listing]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.spacingSM) {
                ForEach(listings) { listing in
                    NavigationLink(value: listing) {
                        ExploreListingCard(listing: listing)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, AppTheme.spacingSM)
        }
        .background(AppTheme.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Listing.self) { listing in
            ListingDetailView(listing: listing)
        }
    }
}

#Preview {
    NavigationStack {
        NearbyListingsView(title: "Nearby Requests", listings: Listing.samples)
            .environmentObject(AppState.shared)
    }
}
