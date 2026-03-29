import SwiftUI

struct MyTradesView: View {
    @State private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Native Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                Spacer()
                Text("Trade History")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                // Mirror the left button for symmetry if needed, or leave empty
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.secondaryBackground)

            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if viewModel.completedTrades.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.textTertiary)
                            Text("No trades yet!")
                                .font(.headline)
                            Text("Your completed exchanges will appear here.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(viewModel.completedTrades) { trade in
                            TradeHistoryRow(trade: trade)
                        }
                    }
                }
                .padding(20)
            }
            .background(AppTheme.background)
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchMyTrades()
        }
    }
}

struct TradeHistoryRow: View {
    let trade: Trade
    
    private var isProvider: Bool {
        trade.provider.id == AuthService.shared.currentUserId
    }
    
    private var partner: User {
        isProvider ? trade.requester : trade.provider
    }
    
    private var creditChange: String {
        let amount = trade.listing.credits
        return isProvider ? "+\(amount)" : "-\(amount)"
    }
    
    private var creditColor: Color {
        isProvider ? .green : .red
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon representing the trade type
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: trade.listing.type == .offer ? "cart.fill" : "hammer.fill")
                    .foregroundColor(AppTheme.accent)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trade.listing.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(isProvider ? "Provided to \(partner.name)" : "Requested from \(partner.name)")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                
                if let completedDate = trade.completedAt {
                    Text(completedDate, format: .dateTime.day().month().year().hour().minute())
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(creditChange)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(creditColor)
                
                Text("credits")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(AppTheme.cornerRadiusLG)
        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
    }
}

#Preview {
    MyTradesView()
}
