import SwiftUI

// MARK: - Trust Score Hero Card (matching reference design)

struct TrustScoreHeroCard: View {
    let trustScore: Double
    let credits: Int
    let tier: AppTheme.TrustTier

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            // Header row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Trust Score")
                        .font(.headline)
                        .foregroundStyle(.white)

                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                        Text(tier.rawValue + " Neighbour")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Button {
                    // View History action
                } label: {
                    Text("View History")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }

            // Score & Credits boxes
            HStack(spacing: AppTheme.spacingMD) {
                // Trust Score box
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("\(Int(trustScore))")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Trust Score")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.white.opacity(0.2))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * animatedProgress / 100, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(AppTheme.spacingMD)
                .background(.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous))

                // Credits box
                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                    Text("\(credits)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Credits")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))

                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(.green)
                        Text("Available")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(AppTheme.spacingMD)
                .background(.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous))
            }
        }
        .padding(AppTheme.spacingXL)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL, style: .continuous)
                .fill(AppTheme.accentGradient)
        )
        .shadow(color: AppTheme.accent.opacity(0.3), radius: 12, x: 0, y: 6)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.3)) {
                animatedProgress = trustScore
            }
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingSM) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingLG)
            .background(color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Nearby Request Card (minimal, reference-style)

struct NearbyRequestCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            // Image or Icon area
            ZStack {
                if let imageUrl = listing.imageUrl {
                    ListingImageView(imageUrl: imageUrl)
                        .frame(height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous)
                        .fill(AppTheme.secondaryAccent.opacity(0.08))
                        .frame(height: 90)

                    Image(systemName: listing.iconName)
                        .font(.largeTitle)
                        .foregroundStyle(AppTheme.secondaryAccent.opacity(0.6))
                }

                // Distance badge
                VStack {
                    HStack {
                        Spacer()
                        Text(listing.shortLocation)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.secondaryAccent)
                            .clipShape(Capsule())
                            .padding(6)
                    }
                    Spacer()
                }
            }
            .frame(height: 90)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous))

            // Title
            Text(listing.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)

            // User + rating
            HStack(spacing: 4) {
                AvatarView(name: listing.ownerName, size: 18)
                Text(listing.ownerName.components(separatedBy: " ").first ?? "")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("•")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.orange)
                Text(String(format: "%.1f", listing.ownerTrustScore / 20.0))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Category + Credits
            HStack {
                Text(listing.category.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.secondaryAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.secondaryAccent.opacity(0.1))
                    .clipShape(Capsule())

                Spacer()

                Text("\(listing.credits) c")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(AppTheme.spacingMD)
        .frame(width: 180)
        .cardStyle()
    }
}

// MARK: - Nearby Offer Card (lightweight, reference-style)

struct NearbyOfferCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            // Image or Icon area
            ZStack {
                if let imageUrl = listing.imageUrl {
                    ListingImageView(imageUrl: imageUrl)
                        .frame(height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous)
                        .fill(AppTheme.accent.opacity(0.08))
                        .frame(height: 90)

                    Image(systemName: listing.iconName)
                        .font(.largeTitle)
                        .foregroundStyle(AppTheme.accent.opacity(0.6))
                }

                // Distance badge
                VStack {
                    HStack {
                        Spacer()
                        Text(listing.shortLocation)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.accent)
                            .clipShape(Capsule())
                            .padding(6)
                    }
                    Spacer()
                }
            }
            .frame(height: 90)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous))

            // Title
            Text(listing.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)

            // User + rating
            HStack(spacing: 4) {
                AvatarView(name: listing.ownerName, size: 18)
                Text(listing.ownerName.components(separatedBy: " ").first ?? "")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("•")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.orange)
                Text(String(format: "%.1f", listing.ownerTrustScore / 20.0))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // Category + Credits
            HStack {
                Text(listing.category.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(listing.credits) TC")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(AppTheme.spacingMD)
        .frame(width: 180)
        .cardStyle()
    }
}
