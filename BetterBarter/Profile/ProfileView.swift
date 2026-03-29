import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var showingEditName = false
    @State private var nameToEdit = ""

    init(user: User = .current) {
        _viewModel = State(initialValue: ProfileViewModel(user: user))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        return NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    // Profile Header
                    VStack(spacing: AppTheme.spacingLG) {
                        AvatarView(name: viewModel.user.name, size: 80)

                        VStack(spacing: 4) {
                            HStack {
                                Text(viewModel.user.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if AuthService.shared.currentUserId == viewModel.user.id {
                                    Button(action: {
                                        nameToEdit = viewModel.user.name
                                        showingEditName = true
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(AppTheme.accent)
                                    }
                                }
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                Text(viewModel.user.location)
                                    .font(.subheadline)
                            }
                            .foregroundStyle(.secondary)

                            Text("Member since \(viewModel.user.joinDate, format: .dateTime.month(.wide).year())")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.top, AppTheme.spacingSM)

                    // Trust Score & Credits row
                    HStack(spacing: AppTheme.spacingLG) {
                        TrustScoreRing(
                            score: viewModel.user.trustScore,
                            tier: viewModel.user.tier
                        )
                        .frame(maxWidth: .infinity)

                        VStack(spacing: AppTheme.spacingMD) {
                            VStack(spacing: 4) {
                                Text("\(viewModel.user.credits)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Credits")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Divider()

                            VStack(spacing: 4) {
                                Text(String(format: "%.1f", viewModel.averageRating))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                    Text("Rating")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(AppTheme.spacingLG)
                    .cardStyle()
                    .padding(.horizontal)

                    // Wallet
                    WalletCard(credits: viewModel.user.credits)
                        .padding(.horizontal)

                    // Skills & Interests
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        SectionHeader(title: "Skills")
                            .padding(.horizontal)

                        FlowLayout(spacing: AppTheme.spacingSM) {
                            ForEach(viewModel.user.skills, id: \.self) { skill in
                                SkillTag(text: skill)
                            }
                        }
                        .padding(.horizontal)

                        SectionHeader(title: "Interests")
                            .padding(.horizontal)
                            .padding(.top, AppTheme.spacingSM)

                        FlowLayout(spacing: AppTheme.spacingSM) {
                            ForEach(viewModel.user.interests, id: \.self) { interest in
                                SkillTag(text: interest)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Active Listings
                    if !viewModel.activeListings.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            SectionHeader(title: "My Listings", action: "Manage")
                                .padding(.horizontal)

                            LazyVStack(spacing: AppTheme.spacingSM) {
                                ForEach(viewModel.activeListings) { listing in
                                    NavigationLink(value: listing) {
                                        ListingCard(listing: listing)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Reviews
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        SectionHeader(title: "Reviews (\(viewModel.reviews.count))")
                            .padding(.horizontal)

                        LazyVStack(spacing: AppTheme.spacingSM) {
                            ForEach(viewModel.reviews) { review in
                                ReviewCard(review: review)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Settings
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: "Settings")
                            .padding(.horizontal)
                            .padding(.bottom, AppTheme.spacingSM)

                        VStack(spacing: 0) {
                            ForEach(viewModel.settingsItems, id: \.1) { item in
                                SettingsRow(icon: item.0, title: item.1)

                                if item.1 != viewModel.settingsItems.last?.1 {
                                    Divider().padding(.leading, 44)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingLG)
                        .padding(.vertical, AppTheme.spacingSM)
                        .cardStyle()
                        .padding(.horizontal)
                    }

                    // Sign Out Section
                    VStack(spacing: AppTheme.spacingMD) {
                        Button(role: .destructive) {
                            try? AuthService.shared.signOut()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        Text("BetterBarter v1.0.0")
                            .font(.caption2)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                    .padding(.top, AppTheme.spacingLG)

                    Spacer(minLength: AppTheme.spacingXXL)
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Profile")
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
            }
            .alert("Edit Name", isPresented: $showingEditName) {
                TextField("New Name", text: $nameToEdit)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    viewModel.updateName(nameToEdit)
                }
            } message: {
                Text("Enter your new display name. This will be updated across the app.")
            }
        }
    }
}

// MARK: - Flow Layout (for tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            if index < result.positions.count {
                subview.place(at: CGPoint(
                    x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y
                ), proposal: .unspecified)
            }
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}

#Preview {
    ProfileView()
}
