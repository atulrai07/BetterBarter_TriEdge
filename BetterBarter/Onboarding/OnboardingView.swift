import SwiftUI

// MARK: - Onboarding Page Model

private struct OnboardingPage {
    let symbol:   String
    let symbolColor: Color
    let title:    String
    let highlight: String   // word(s) in title to tint teal
    let subtitle: String
}

private let pages: [OnboardingPage] = [
    OnboardingPage(
        symbol: "arrow.left.arrow.right.circle.fill",
        symbolColor: Color(hue: 0.08, saturation: 0.55, brightness: 0.96),
        title: "Trade What You Have",
        highlight: "You Have",
        subtitle: "Exchange skills or items with neighbors without spending a cent."
    ),
    OnboardingPage(
        symbol: "clock.badge.checkmark.fill",
        symbolColor: Color(hue: 0.47, saturation: 0.65, brightness: 0.72),
        title: "Earn Credits",
        highlight: "Credits",
        subtitle: "30 min of your time equals 10 credits. Use your earned credits to get help from others."
    ),
    OnboardingPage(
        symbol: "checkmark.shield.fill",
        symbolColor: Color(hue: 0.47, saturation: 0.65, brightness: 0.72),
        title: "Built on Trust",
        highlight: "Trust",
        subtitle: "Video-verified skills and neighbor endorsements ensure a safe and reliable community."
    ),
    OnboardingPage(
        symbol: "mappin.and.ellipse",
        symbolColor: Color(hue: 0.47, saturation: 0.65, brightness: 0.72),
        title: "Meet Safely",
        highlight: "Safely",
        subtitle: "Choose from certified community Safe Spots for your exchanges."
    )
]

// MARK: - Onboarding View

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            // Page switcher
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Bottom section: dots + button
            VStack(spacing: 28) {
                // Page dots
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? AppTheme.accent : Color(.systemGray4))
                            .frame(width: i == currentPage ? 20 : 7, height: 7)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }

                // Next / Done button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        appState.hasSeenOnboarding = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Done")
                            .font(.system(size: 18, weight: .medium, design: .default))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .medium, design: .default))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.accent)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
            }
            .padding(.bottom, 40)
            .padding(.top, 8)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Single Page

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Illustration area
            ZStack {
                // Soft background blob
                Circle()
                    .fill(page.symbolColor.opacity(0.12))
                    .frame(width: 240, height: 240)

                Circle()
                    .fill(page.symbolColor.opacity(0.08))
                    .frame(width: 300, height: 300)

                Image(systemName: page.symbol)
                    .font(.system(size: 110, weight: .light))
                    .foregroundStyle(page.symbolColor)
                    .symbolRenderingMode(.hierarchical)
            }
            .frame(height: 280)

            Spacer().frame(height: 40)

            // Title with teal highlighted word
            highlightedTitle(title: page.title, highlight: page.highlight)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer().frame(height: 14)

            // Subtitle
            Text(page.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 36)

            Spacer()
        }
    }

    private func highlightedTitle(title: String, highlight: String) -> some View {
        // Build an attributed string with the highlighted portion tinted teal
        var attributed = AttributedString(title)
        if let range = attributed.range(of: highlight) {
            attributed[range].foregroundColor = UIColor(AppTheme.accent)
        }
        return Text(attributed)
            .font(.title2.weight(.bold))
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState.shared)
}
