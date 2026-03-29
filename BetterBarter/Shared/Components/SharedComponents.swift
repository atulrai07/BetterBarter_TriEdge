import SwiftUI

// MARK: - Avatar View

struct AvatarView: View {
    let name: String
    let size: CGFloat

    private var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }

    private var backgroundColor: Color {
        let hash = abs(name.hashValue)
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.45, brightness: 0.85)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor.gradient)
                .frame(width: size, height: size)

            Text(initials)
                .font(.system(size: size * 0.36, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Trust Badge

struct TrustBadge: View {
    let score: Double

    private var tier: AppTheme.TrustTier {
        AppTheme.TrustTier.from(score: score)
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: tier.icon)
                .font(.caption2)
            Text(tier.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(tier.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tier.color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Trade Status Badge

struct TradeStatusBadge: View {
    let status: Trade.TradeStatus

    private var color: Color {
        switch status {
        case .pending: return .orange
        case .active: return AppTheme.accent
        case .providerConfirmed, .requesterConfirmed: return AppTheme.accent
        case .completed: return .green
        case .cancelled: return .red
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Credit Indicator

struct CreditIndicator: View {
    let amount: Int
    var showPlus: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "bitcoinsign.circle.fill")
                .foregroundStyle(AppTheme.accent)
            Text(showPlus && amount > 0 ? "+\(amount)" : "\(amount)")
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .font(.subheadline)
    }
}

// MARK: - Listing Card

struct ListingCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            // Header
            HStack(spacing: AppTheme.spacingSM) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSM, style: .continuous)
                        .fill(listing.type == .offer
                              ? AppTheme.accent.opacity(0.12)
                              : AppTheme.secondaryAccent.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: listing.iconName)
                        .font(.title3)
                        .foregroundStyle(listing.type == .offer ? AppTheme.accent : AppTheme.secondaryAccent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.title)
                        .font(.headline)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(listing.ownerName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TrustBadge(score: listing.ownerTrustScore)
                    }
                }

                Spacer()

                CreditIndicator(amount: listing.credits)
            }

            // Description
            Text(listing.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            // Footer
            HStack {
                Label(listing.distance, systemImage: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Spacer()

                Text(listing.type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(listing.type == .offer ? AppTheme.accent : AppTheme.secondaryAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((listing.type == .offer ? AppTheme.accent : AppTheme.secondaryAccent).opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(AppTheme.spacingLG)
        .cardStyle()
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)

            Spacer()

            if let action = action {
                Button(action) {
                    onAction?()
                }
                .font(.subheadline)
                .foregroundStyle(AppTheme.accent)
            }
        }
    }
}

