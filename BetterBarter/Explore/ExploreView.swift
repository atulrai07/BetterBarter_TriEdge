import SwiftUI

struct ExploreView: View {
    @State private var viewModel = ExploreViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.spacingSM) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            CategoryChip(
                                category: category,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, AppTheme.spacingSM)
                }

                // Native iOS Segmented Control
                Picker("Listing Type", selection: $viewModel.selectedSegment) {
                    ForEach(ExploreViewModel.SegmentOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, AppTheme.spacingSM)

                // Results
                ScrollView {
                    LazyVStack(spacing: AppTheme.spacingSM) {
                        if viewModel.filteredListings.isEmpty {
                            ContentUnavailableView(
                                "No listings found",
                                systemImage: "magnifyingglass",
                                description: Text("Try adjusting your filters or search terms.")
                            )
                            .padding(.top, 60)
                        } else {
                            ForEach(viewModel.filteredListings) { listing in
                                NavigationLink(value: listing) {
                                    ExploreListingCard(listing: listing)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, AppTheme.spacingSM)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Explore")
            .searchable(text: $viewModel.searchText, prompt: "Search skills, services, goods...")
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
            }
        }
    }
}

#Preview {
    ExploreView()
        .environmentObject(AppState.shared)
}
