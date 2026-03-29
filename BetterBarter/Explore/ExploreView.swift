import SwiftUI

struct ExploreView: View {
    @State private var viewModel = ExploreViewModel()
    @State private var navigationPath = NavigationPath()
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                .padding(.bottom,8)

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
        .onChange(of: appState.focusedListingId) { _, newValue in
            if let id = newValue {
                Task {
                    if let listing = try? await FirebaseDataService.shared.getListing(id: id) {
                        await MainActor.run {
                            navigationPath.append(listing)
                            appState.focusedListingId = nil // Consume link
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ExploreView()
        .environmentObject(AppState.shared)
}
