import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var showNearbyRequests = false
    @State private var showNearbyOffers = false
    @State private var showCreatePost = false
    @State private var createPostInitialType: Listing.ListingType = .offer
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header: Greeting + Avatar
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.greeting)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.accent)
                        Text(viewModel.userName)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    HStack(spacing: AppTheme.spacingMD) {
                        Button {
                            // Notifications
                        } label: {
                            Image(systemName: "bell.fill")
                                .font(.title3)
                                .foregroundStyle(.primary)
                        }

                        Button {
                            showProfile = true
                        } label: {
                            AvatarView(name: viewModel.userName, size: 40)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, AppTheme.spacingSM)
                .padding(.bottom, AppTheme.spacingLG)

                // Scrollable content area (but feels focused, not feed-like)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppTheme.spacingXL) {
                        // Trust Score Hero Card
                        TrustScoreHeroCard(
                            trustScore: viewModel.trustScore,
                            credits: viewModel.creditBalance,
                            tier: viewModel.userTier
                        )
                        .padding(.horizontal)

                        // Quick Action Buttons
                        HStack(spacing: AppTheme.spacingMD) {
                            QuickActionButton(
                                title: "Request Help",
                                icon: "hand.raised.fill",
                                color: AppTheme.accent
                            ) {
                                createPostInitialType = .request
                                showCreatePost = true
                            }

                            QuickActionButton(
                                title: "Offer Skill",
                                icon: "chart.line.uptrend.xyaxis",
                                color: AppTheme.secondaryAccent
                            ) {
                                createPostInitialType = .offer
                                showCreatePost = true
                            }
                        }
                        .padding(.horizontal)

                        // Nearby Requests (horizontal scroll, 1 visible at a time)
                        if !viewModel.nearbyRequests.isEmpty {
                            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                                SectionHeader(title: "Nearby Requests", action: "See All") {
                                    showNearbyRequests = true
                                }
                                .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.spacingMD) {
                                        ForEach(viewModel.nearbyRequests) { listing in
                                            NavigationLink(value: listing) {
                                                NearbyRequestCard(listing: listing)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        // Nearby Offers (horizontal scroll, 1 visible at a time)
                        if !viewModel.nearbyOffers.isEmpty {
                            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                                SectionHeader(title: "Nearby Offers", action: "See All") {
                                    showNearbyOffers = true
                                }
                                .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.spacingMD) {
                                        ForEach(viewModel.nearbyOffers) { listing in
                                            NavigationLink(value: listing) {
                                                NearbyOfferCard(listing: listing)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        Spacer(minLength: AppTheme.spacingXL)
                    }
                    .padding(.top, AppTheme.spacingXS)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .background(AppTheme.background)
            .navigationBarHidden(true)
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
            }
            .navigationDestination(isPresented: $showNearbyRequests) {
                NearbyListingsView(
                    title: "Nearby Requests",
                    listings: viewModel.nearbyRequests
                )
            }
            .navigationDestination(isPresented: $showNearbyOffers) {
                NearbyListingsView(
                    title: "Nearby Offers",
                    listings: viewModel.nearbyOffers
                )
            }
            .sheet(isPresented: $showCreatePost, onDismiss: {
                Task { await viewModel.refresh() }
            }) {
                CreatePostView(initialType: createPostInitialType)
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState.shared)
}
