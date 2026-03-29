import SwiftUI

// MARK: - App Theme

enum AppTheme {

    // MARK: Colors

    static let accent = Color(hue: 0.45, saturation: 0.72, brightness: 0.68)        // Teal
    static let accentLight = Color(hue: 0.45, saturation: 0.35, brightness: 0.95)
    static let secondaryAccent = Color(hue: 0.08, saturation: 0.78, brightness: 0.96) // Warm coral
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let subtitleGray = Color(.secondaryLabel)

    // MARK: Semantic Colors

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color.secondary.opacity(0.7)
    static let secondaryBackground = Color(.systemGroupedBackground)
    static let error = Color.red

    // MARK: Gradients

    static let accentGradient = LinearGradient(
        colors: [Color(hue: 0.45, saturation: 0.72, brightness: 0.68),
                 Color(hue: 0.50, saturation: 0.65, brightness: 0.80)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [Color(hue: 0.08, saturation: 0.78, brightness: 0.96),
                 Color(hue: 0.12, saturation: 0.70, brightness: 0.98)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [Color(hue: 0.11, saturation: 0.75, brightness: 0.92),
                 Color(hue: 0.13, saturation: 0.60, brightness: 0.98)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // MARK: Corner Radii

    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 12
    static let cornerRadiusLG: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 20

    // MARK: Shadows

    static let cardShadow = ShadowStyle.drop(
        color: .black.opacity(0.06), radius: 8, x: 0, y: 4
    )

    // MARK: Trust Tiers

    enum TrustTier: String, CaseIterable {
        case bronze = "Bronze"
        case silver = "Silver"
        case gold = "Gold"
        case platinum = "Platinum"

        var color: Color {
            switch self {
            case .bronze: return Color(hue: 0.07, saturation: 0.65, brightness: 0.72)
            case .silver: return Color(hue: 0.0, saturation: 0.0, brightness: 0.72)
            case .gold: return Color(hue: 0.12, saturation: 0.80, brightness: 0.88)
            case .platinum: return Color(hue: 0.55, saturation: 0.35, brightness: 0.80)
            }
        }

        var icon: String {
            switch self {
            case .bronze: return "shield"
            case .silver: return "shield.lefthalf.filled"
            case .gold: return "shield.fill"
            case .platinum: return "crown.fill"
            }
        }

        static func from(score: Double) -> TrustTier {
            switch score {
            case 0..<30: return .bronze
            case 30..<60: return .silver
            case 60..<85: return .gold
            default: return .platinum
            }
        }
    }
}

// MARK: - View Modifiers

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }

    func modernCardStyle() -> some View {
        self
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
