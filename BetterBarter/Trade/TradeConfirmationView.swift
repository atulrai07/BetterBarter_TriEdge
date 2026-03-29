import SwiftUI
import Combine

struct TradeConfirmationView: View {
    let trade: Trade
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var navigateToActiveTrade = false

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
                Text("Confirm Trade")
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
                    // Transaction Visualization
                    HStack(spacing: 20) {
                        TradeUserNode(user: trade.requester, label: "You")
                        
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.accent)
                            Text("\(trade.listing.credits) tc")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.accent)
                        }
                        .frame(width: 60)
                        
                        TradeUserNode(user: trade.provider, label: trade.provider.name)
                    }
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.05), radius: 15, y: 10)
                    .padding(.horizontal, 24)

                    // Listing Details Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Trade Details")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        HStack(spacing: 12) {
                            Image(systemName: trade.listing.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.accent)
                                .frame(width: 44, height: 44)
                                .background(AppTheme.accent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(trade.listing.title)
                                    .font(.system(size: 16, weight: .bold))
                                Text(trade.listing.category.rawValue)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Included in Trade")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.accent)
                                Text("Service completion as described")
                                    .font(.system(size: 14))
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.accent)
                                Text("Tools & materials provided by \(trade.provider.name)")
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    .padding(24)
                    .modernCardStyle()
                    .padding(.horizontal, 24)

                    // Credit Breakdown
                    VStack(spacing: 16) {
                        HStack {
                            Text("You will PAY")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("\(trade.listing.credits)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.error)
                                Text("tc")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.error)
                            }
                        }
                        
                        Text("Your remaining balance will be 450 tc")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding(24)
                    .background(AppTheme.error.opacity(0.05))
                    .cornerRadius(20)
                    .padding(.horizontal, 24)

                    // Disclaimer
                    Text("By confirming, you agree to the community guidelines. Credits will be held in escrow until completion.")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                }
                .padding(.bottom, 120)
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
            Button(action: {
                Task {
                    do {
                        try await FirebaseDataService.shared.createTrade(trade)
                        
                        // Detect current user ID
                        let currentUserId = AuthService.shared.currentUser?.id ?? ""
                        // The recipient should be the other person in the trade
                        let recipientId = (trade.requester.id == currentUserId) ? trade.provider.id : trade.requester.id
                        // The sender name is the current user's name
                        let senderName = (trade.requester.id == currentUserId) ? trade.requester.name : trade.provider.name
                        
                        print("Creating notification for: \(recipientId) from: \(senderName)")

                        let notification = AppNotification(
                            id: UUID().uuidString,
                            recipientId: recipientId,
                            senderId: currentUserId,
                            senderName: senderName,
                            listingId: trade.listing.id,
                            listingTitle: trade.listing.title,
                            tradeId: trade.id,
                            isRead: false,
                            createdAt: Date(),
                            type: .tradeRequest
                        )
                        
                        try await FirebaseDataService.shared.createNotification(notification)
                        print("Notification created successfully!")
                        
                        await MainActor.run {
                            appState.isTabBarHidden = true
                            navigateToActiveTrade = true
                        }
                    } catch {
                        print("Error in trade/notification process: \(error.localizedDescription)")
                    }
                }
            }) {
                HStack {
                    Text("Confirm & Send Request")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                }
                .padding(.horizontal, 24)
                .frame(height: 64)
                .background(AppTheme.accent)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .navigationDestination(isPresented: $navigateToActiveTrade) {
                TradeActiveView(trade: trade)
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

struct TradeUserNode: View {
    let user: User
    let label: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .foregroundColor(AppTheme.textTertiary)
                
                Circle()
                    .fill(AppTheme.accent)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .bold))
                Text("\(Int(user.trustScore)) Trust")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.accent)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TradeConfirmationView(trade: Trade.samples.first!)
            .environmentObject(AppState.shared)
    }
}
