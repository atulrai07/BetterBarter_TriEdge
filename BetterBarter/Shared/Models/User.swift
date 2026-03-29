import Foundation

struct User: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var avatarName: String
    var location: String
    var trustScore: Double
    var credits: Int
    var skills: [String]
    var interests: [String]
    var joinDate: Date

    var tier: AppTheme.TrustTier {
        AppTheme.TrustTier.from(score: trustScore)
    }
}

// MARK: - Sample Data

extension User {
    static let current = User(
        id: "placeholder_user",
        name: "Neighbor",
        avatarName: "person.circle.fill",
        location: "Your Neighborhood",
        trustScore: 50,
        credits: 100,
        skills: [],
        interests: [],
        joinDate: .now
    )

    static let sampleNeighbors: [User] = [
        User(id: "user_priya_sharma", name: "Priya Sharma", avatarName: "person.circle.fill",
             location: "0.3 km away", trustScore: 92, credits: 380,
             skills: ["Yoga", "Cooking"], interests: ["Wellness"],
             joinDate: Calendar.current.date(byAdding: .month, value: -12, to: .now)!),

        User(id: "user_arjun_patel", name: "Arjun Patel", avatarName: "person.circle.fill",
             location: "0.8 km away", trustScore: 65, credits: 120,
             skills: ["Plumbing", "Carpentry"], interests: ["DIY"],
             joinDate: Calendar.current.date(byAdding: .month, value: -3, to: .now)!),

        User(id: "user_maya_chen", name: "Maya Chen", avatarName: "person.circle.fill",
             location: "1.2 km away", trustScore: 88, credits: 540,
             skills: ["Tutoring", "Design"], interests: ["Education"],
             joinDate: Calendar.current.date(byAdding: .month, value: -9, to: .now)!),

        User(id: "user_rohan_kumar", name: "Rohan Kumar", avatarName: "person.circle.fill",
             location: "0.5 km away", trustScore: 45, credits: 80,
             skills: ["Dog Walking", "Cleaning"], interests: ["Pets"],
             joinDate: Calendar.current.date(byAdding: .month, value: -1, to: .now)!),
    ]
}
