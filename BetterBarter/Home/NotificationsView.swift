import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var notifications: [AppNotification] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if notifications.isEmpty {
                    ContentUnavailableView(
                        "No Notifications",
                        systemImage: "bell.slash",
                        description: Text("You don't have any trade requests yet.")
                    )
                } else {
                    List {
                        ForEach(notifications) { notification in
                            NotificationRow(notification: notification)
                                .onTapGesture {
                                    handleNotificationTap(notification)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadNotifications()
            }
        }
    }
    
    private func loadNotifications() {
        guard let currentUser = AuthService.shared.currentUser else { return }
        
        // Let's use simple async fetch for now to keep things robust, 
        // a listener could also be used here if needed
        Task {
            do {
                let fetched = try await FirebaseDataService.shared.getNotifications(userId: currentUser.id)
                await MainActor.run {
                    self.notifications = fetched
                    self.isLoading = false
                }
            } catch {
                print("Error loading notifications: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func handleNotificationTap(_ notification: AppNotification) {
        // Mark as read
        if !notification.isRead {
            Task {
                try? await FirebaseDataService.shared.markNotificationRead(id: notification.id)
            }
            // Update local state optimisticly
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index].isRead = true
            }
        }
        
        // Deep link into Explore Tab
        dismiss()
        
        // Allow dismiss animation to finish before switching tabs
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            appState.focusedListingId = notification.listingId
            appState.focusedTradeId = notification.tradeId
            appState.activeTab = .explore
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "arrow.right.arrow.left")
                    .foregroundColor(AppTheme.accent)
                    .font(.system(size: 20))
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(notification.senderName)
                        .fontWeight(.bold)
                    Text("wants to trade:")
                }
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textPrimary)
                
                Text(notification.listingTitle)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(timeString(from: notification.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Unread indicator
            if !notification.isRead {
                Circle()
                    .fill(AppTheme.accent)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Makes the whole row tappable
    }
    
    // Simple relative time formatter
    private func timeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
