import SwiftUI
import Combine
import MapKit
import FirebaseFirestore

struct ListingDetailView: View {
    let listing: Listing
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    ))
    
    @State private var existingTrade: Trade? = nil
    @State private var isLoadingTrade: Bool = true
    
    // Construct a User from the listing's denormalized data
    private var listingOwner: User {
        User(
            id: listing.ownerID,
            name: listing.ownerName,
            avatarName: listing.ownerAvatar,
            location: "Unknown", // Can be fetched later if needed
            trustScore: listing.ownerTrustScore,
            credits: 0,
            skills: [],
            interests: [],
            joinDate: Date()
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image
                ZStack(alignment: .top) {
                    // Image Placeholder
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(.systemGray6))
                        .frame(height: 320)
                        .overlay(
                            Image(systemName: listing.iconName)
                                .font(.system(size: 80))
                                .foregroundColor(AppTheme.accent.opacity(0.2))
                        )
                }

                VStack(alignment: .leading, spacing: 24) {
                    // Title and Basic Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(listing.category.rawValue.uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AppTheme.accent.opacity(0.1))
                                .clipShape(Capsule())
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                Text("2d ago")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(AppTheme.textTertiary)
                        }
                        
                        Text(listing.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                            Text("\(listing.shortLocation) away")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Host Card
                    NavigationLink(destination: ProfileView(user: listingOwner)) {
                        HostCard(user: listingOwner)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)

                    // Offering/Requesting Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(listing.type == .offer ? "OFFERING" : "REQUESTING")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        HStack(spacing: 12) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(listing.credits)")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.accent)
                                Text("tc")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.accent)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Market Value")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.textTertiary)
                                Text("~ $50.00")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24)

                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text(listing.description)
                            .font(.system(size: 16))
                            .lineSpacing(6)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.horizontal, 24)

                    // Map View (Compact)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Map(position: $position) {
                            if let lat = listing.latitude, let lon = listing.longitude {
                                Marker(listing.title, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                            }
                        }
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        Text("Exact location shared after trade adoption.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120) // Extra padding for button
                }
                .background(AppTheme.secondaryBackground)
                .cornerRadius(32, corners: [.topLeft, .topRight])
                .offset(y: -30)
            }
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.secondaryBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if let lat = listing.latitude, let lon = listing.longitude {
                position = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            }
            Task {
                if let uid = AuthService.shared.currentUserId {
                    let snapshot = try? await Firestore.firestore().collection("trades")
                        .whereField("listing.id", isEqualTo: listing.id)
                        .whereField("requester.id", isEqualTo: uid)
                        .getDocuments()
                    if let doc = snapshot?.documents.first, let trade = try? doc.data(as: Trade.self) {
                        await MainActor.run {
                            self.existingTrade = trade
                            self.isLoadingTrade = false
                        }
                    } else {
                        await MainActor.run { self.isLoadingTrade = false }
                    }
                } else {
                    await MainActor.run { self.isLoadingTrade = false }
                }
            }
        }
        .onDisappear {
        }
        .overlay(alignment: .bottom) {
            // Floating Bottom Button
            if let currentUser = AuthService.shared.currentUser, currentUser.id != listing.ownerID {
                if isLoadingTrade {
                    HStack {
                        ProgressView()
                            .tint(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppTheme.accent.opacity(0.5))
                    .clipShape(Capsule())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                } else if let trade = existingTrade {
                    if trade.status == .completed {
                        HStack {
                            Text("Trade Completed")
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 64)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.horizontal, 24)
                        .padding(.bottom, 34)
                    } else {
                        NavigationLink(destination: TradeActiveView(trade: trade)) {
                            HStack {
                                Text("Resume Trade")
                                    .font(.system(size: 18, weight: .bold))
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 64)
                            .background(AppTheme.accent)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: AppTheme.accent.opacity(0.3), radius: 15, x: 0, y: 8)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 34)
                    }
                } else {
                    let isOffer = listing.type == .offer
                    let tradeRequester = isOffer ? currentUser : listingOwner
                    let tradeProvider = isOffer ? listingOwner : currentUser
                    
                    NavigationLink(destination: TradeConfirmationView(trade: Trade(id: "trade_\(UUID().uuidString)", listing: listing, requester: tradeRequester, provider: tradeProvider, status: .pending, createdAt: Date(), messages: []))) {
                        HStack {
                            Text("Start Trade")
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 64)
                        .background(AppTheme.accent)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
        }
    }
}

struct HostCard: View {
    let user: User

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(AppTheme.textTertiary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.system(size: 16, weight: .bold))
                
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text("4.9")
                            .font(.system(size: 13, weight: .bold))
                    }
                    Text("•")
                        .foregroundColor(AppTheme.textTertiary)
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.accent)
                        Text("Top Trader")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            
            Spacer()
            
            NavigationLink(destination: DirectChatView(recipient: user)) {
                Image(systemName: "bubble.left.fill")
                    .font(.title3)
                    .foregroundColor(AppTheme.accent)
                    .padding(10)
                    .background(AppTheme.accent.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

// Extensions for specific corner rounding
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    ListingDetailView(listing: Listing.samples.first!)
        .environmentObject(AppState.shared)
}
