import SwiftUI
import Combine

struct TradeActiveView: View {
    @State private var viewModel: ActiveTradeViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    init(trade: Trade) {
        self._viewModel = State(initialValue: ActiveTradeViewModel(trade: trade))
    }

    private var partnerName: String {
        let currentUserId = AuthService.shared.currentUserId ?? ""
        return viewModel.trade.requester.id == currentUserId ? viewModel.trade.provider.name : viewModel.trade.requester.name
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                Spacer()
                Text("Active Trade")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            ScrollView {
                VStack(spacing: 32) {
                    // Status Badge
                    HStack(spacing: 8) {
                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: 10, height: 10)
                        Text(viewModel.trade.status.rawValue.capitalized)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.accent.opacity(0.1))
                    .clipShape(Capsule())
                    .padding(.top, 16)

                    // Transaction Visualization
                    HStack(spacing: 20) {
                        TradeUserNode(user: viewModel.trade.requester, label: viewModel.trade.requester.id == AuthService.shared.currentUserId ? "You" : viewModel.trade.requester.name)
                        
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.accent)
                            Text("\(viewModel.trade.listing.credits) tc")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.accent)
                        }
                        .frame(width: 60)
                        
                        TradeUserNode(user: viewModel.trade.provider, label: viewModel.trade.provider.id == AuthService.shared.currentUserId ? "You" : viewModel.trade.provider.name)
                    }
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.05), radius: 15, y: 10)
                    .padding(.horizontal, 24)

                    // Listing Details Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Listing Details")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.trade.listing.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.accent)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.accent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.trade.listing.title)
                                    .font(.system(size: 16, weight: .bold))
                                Text(viewModel.trade.listing.category.rawValue)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                    .padding(24)
                    .modernCardStyle()
                    .padding(.horizontal, 24)

                    if viewModel.trade.status != .completed {
                        // Secondary Actions
                        VStack(spacing: 16) {
                            NavigationLink(destination: DirectChatView(recipient: viewModel.trade.requester.id == AuthService.shared.currentUserId ? viewModel.trade.provider : viewModel.trade.requester)) {
                                HStack {
                                    Image(systemName: "bubble.left.fill")
                                    Text("Message \(partnerName)")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { viewModel.cancelTrade() }) {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Cancel Trade")
                                    Spacer()
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.error)
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 24)
                    } else {
                        // Testimonials
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Trade Testimonials")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            
                            if viewModel.tradeReviews.isEmpty {
                                Text("Awaiting reviews...")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textTertiary)
                            } else {
                                ForEach(viewModel.tradeReviews) { review in
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            HStack(spacing: 8) {
                                                Image(systemName: "person.circle.fill")
                                                    .foregroundColor(AppTheme.textTertiary)
                                                    .font(.system(size: 24))
                                                Text(review.reviewerName)
                                                    .font(.system(size: 14, weight: .bold))
                                            }
                                            Spacer()
                                            HStack(spacing: 2) {
                                                ForEach(1...5, id: \.self) { star in
                                                    Image(systemName: star <= review.rating ? "star.fill" : "star")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(star <= review.rating ? .yellow : AppTheme.textTertiary)
                                                }
                                            }
                                        }
                                        if !review.comment.isEmpty {
                                            Text(review.comment)
                                                .font(.system(size: 14))
                                                .foregroundColor(AppTheme.textSecondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 150)
            }
        }
        .background(AppTheme.secondaryBackground)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                appState.isTabBarHidden = true
            }
        }
        .overlay(alignment: .bottom) {
            // Floating Bottom Button
            if viewModel.trade.status != .completed {
                VStack(spacing: 12) {
                    if viewModel.hasConfirmed {
                        HStack {
                            Image(systemName: "clock.badge.checkmark.fill")
                            Text("Waiting for \(viewModel.isProvider ? "Requester" : "Provider")")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 64)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .foregroundColor(AppTheme.textSecondary)
                        .clipShape(Capsule())
                    } else {
                        NavigationLink(destination: CompletionReviewView(trade: viewModel.trade)) {
                            HStack {
                                Text(viewModel.isProvider ? "Service Provided" : "Service Received")
                                    .font(.system(size: 18, weight: .bold))
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 64)
                            .background(AppTheme.accent)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: AppTheme.accent.opacity(0.3), radius: 15, x: 0, y: 8)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                             viewModel.confirmService()
                        })
                    }
                    
                    if viewModel.otherConfirmed && !viewModel.hasConfirmed {
                        Text("\(viewModel.isProvider ? "The requester" : "The provider") has already confirmed.")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.clear, AppTheme.secondaryBackground]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 120)
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        TradeActiveView(trade: Trade.samples.first!)
            .environmentObject(AppState.shared)
    }
}
