import SwiftUI
import Combine

struct CompletionReviewView: View {
    let trade: Trade
    @Environment(\.dismiss) var dismiss
    @State private var rating = 0
    @State private var reviewText = ""
    @State private var showSuccess = true
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                Spacer()
                Text("Review Trade")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Color.clear.frame(width: 20)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(AppTheme.secondaryBackground)

            ScrollView {
                VStack(spacing: 24) {
                    // Success Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accent.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.accent)
                        }
                        
                        VStack(spacing: 8) {
                            let isProvider = trade.provider.id == User.current.id
                            let otherConfirmed = (isProvider && trade.status == .requesterConfirmed) || (!isProvider && trade.status == .providerConfirmed)
                            
                            Text(otherConfirmed ? "Finalize Trade" : "Complete Service")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            
                            Text("Confirm your completion and rate your experience with **\(isProvider ? trade.requester.name : trade.provider.name)**.")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 24)

                    // Rating Section
                    VStack(spacing: 24) {
                        Text("How was your experience?")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .font(.system(size: 36))
                                    .foregroundColor(index <= rating ? .yellow : AppTheme.textTertiary)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            rating = index
                                        }
                                    }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Write a Testimonial")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextEditor(text: $reviewText)
                                .frame(height: 120)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                                .font(.system(size: 15))
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.05), radius: 15, y: 10)
                    .padding(.horizontal, 24)
                    
                    // Community Impact
                    HStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(AppTheme.accent)
                        Text("Your review helps build neighborhood trust.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.bottom, 60)
                }
            }
            .background(AppTheme.secondaryBackground)

            // Submit Button
            VStack {
                Button(action: {
                    guard let currentUserId = AuthService.shared.currentUserId else { return }
                    
                    let isProvider = trade.provider.id == currentUserId
                    let partner = isProvider ? trade.requester : trade.provider
                    
                    let reviewId = "rev_\(UUID().uuidString)"
                    let currentUser = AuthService.shared.currentUser
                    
                    let newReview = Review(
                        id: reviewId,
                        reviewerId: currentUserId,
                        reviewerName: currentUser?.name ?? "Neighbor",
                        reviewerAvatar: "person.circle.fill",
                        receiverId: partner.id,
                        tradeId: trade.id,
                        rating: rating,
                        comment: reviewText,
                        date: Date()
                    )
                    
                    Task {
                        // 1. Create the review document
                        try? await FirebaseDataService.shared.createReview(newReview)
                        
                        // 2. Finalize the trade status
                        try? await FirebaseDataService.shared.confirmTrade(trade.id, byUser: currentUserId)
                        
                        // 3. Update partner trust score (simplified logic for demo)
                        let newTrustScore = min(100, partner.trustScore + (Double(rating) * 0.5))
                        try? await FirebaseDataService.shared.updateTrustScore(userId: partner.id, newScore: newTrustScore)
                        
                        await MainActor.run {
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        Text("Confirm & Submit Review")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .padding(.horizontal, 24)
                    .frame(height: 64)
                    .background(rating > 0 ? AppTheme.accent : AppTheme.textTertiary)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: rating > 0 ? AppTheme.accent.opacity(0.3) : .clear, radius: 15, x: 0, y: 8)
                }
                .disabled(rating == 0)
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            .background(AppTheme.secondaryBackground)
        }
        .background(AppTheme.secondaryBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                appState.isTabBarHidden = true
            }
        }
    }
}

#Preview {
    CompletionReviewView(trade: Trade.samples.first!)
        .environmentObject(AppState.shared)
}
