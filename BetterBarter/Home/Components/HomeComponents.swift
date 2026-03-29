import SwiftUI
import CoreLocation

// MARK: - Trust Score Hero Card (matching reference design)

struct TrustScoreHeroCard: View {
    let trustScore: Double
    let credits: Int
    let tier: AppTheme.TrustTier

    @State private var animatedProgress: Double = 0
    
    // Custom colors matching the image
    private let cardBg = Color(red: 24/255, green: 164/255, blue: 160/255) // Teal background
    private let textYellow = Color(red: 254/255, green: 203/255, blue: 13/255) // Yellow
    
    var body: some View {
        VStack(spacing: 20) {
            // Header row
            HStack {
                Text("Your Trust Score")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button {
                    // View History action
                } label: {
                    Text("View History")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(textYellow)
                }
            }
            
            // Content row
            HStack {
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(.white, lineWidth: 10)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(animatedProgress / 100))
                        .stroke(textYellow, style: StrokeStyle(lineWidth: 10, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(Int(trustScore))%")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Trust Score")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 90, height: 90)
                
                Spacer()
                
                // Credits
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(credits)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Credits\nAvailable")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBg)
        )
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
    let userLocation: CLLocation?

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
                        Text(listing.formattedDistance(from: userLocation))
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
    let userLocation: CLLocation?

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
                        Text(listing.formattedDistance(from: userLocation))
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
