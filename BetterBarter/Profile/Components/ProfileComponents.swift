import SwiftUI

// MARK: - Trust Score Ring

struct TrustScoreRing: View {
    let score: Double
    let tier: AppTheme.TrustTier
    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(spacing: AppTheme.spacingSM) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(tier.color.opacity(0.15), lineWidth: 8)
                    .frame(width: 90, height: 90)

                // Progress ring
                Circle()
                    .trim(from: 0, to: animatedProgress / 100)
                    .stroke(
                        tier.color,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))

                // Score
                VStack(spacing: 0) {
                    Text("\(Int(score))")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Trust")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: tier.icon)
                    .font(.caption)
                Text(tier.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(tier.color)
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.3)) {
                animatedProgress = score
            }
        }
    }
}

// MARK: - Wallet Card

struct WalletCard: View {
    let credits: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Credit Wallet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.accent)
                    Text("\(credits)")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }

            Spacer()

            VStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.accent)
                Text("History")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(AppTheme.spacingLG)
        .cardStyle()
    }
}

// MARK: - Skill Tag

struct SkillTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(AppTheme.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.accent.opacity(0.1))
            .clipShape(Capsule())
    }
}

// MARK: - Review Card

struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            HStack(spacing: AppTheme.spacingSM) {
                AvatarView(name: review.reviewerName, size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.reviewerName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(review.date, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundStyle(star <= review.rating ? Color.orange : Color.gray.opacity(0.4))
                    }
                }
            }

            Text(review.comment)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(AppTheme.spacingLG)
        .cardStyle()
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 28)

            Text(title)
                .font(.body)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, AppTheme.spacingSM)
    }
}
