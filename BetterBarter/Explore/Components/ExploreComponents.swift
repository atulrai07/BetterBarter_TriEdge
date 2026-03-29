import SwiftUI

// MARK: - Category Chip

struct CategoryChip: View {
    let category: Listing.Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.accent : AppTheme.cardBackground)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .shadow(color: isSelected ? AppTheme.accent.opacity(0.3) : .clear, radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}



// MARK: - Explore Listing Card (compact)

struct ExploreListingCard: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous)
                    .fill(listing.type == .offer
                          ? AppTheme.accent.opacity(0.12)
                          : AppTheme.secondaryAccent.opacity(0.12))
                    .frame(width: 50, height: 50)

                Image(systemName: listing.iconName)
                    .font(.title3)
                    .foregroundStyle(listing.type == .offer ? AppTheme.accent : AppTheme.secondaryAccent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    AvatarView(name: listing.ownerName, size: 18)
                    Text(listing.ownerName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Label(listing.distance, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                CreditIndicator(amount: listing.credits)

                Text(listing.type.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(listing.type == .offer ? AppTheme.accent : AppTheme.secondaryAccent)
            }
        }
        .padding(AppTheme.spacingLG)
        .cardStyle()
    }
}
