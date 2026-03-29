import Foundation

struct Review: Identifiable, Hashable, Codable {
    let id: String
    var reviewerId: String
    var reviewerName: String
    var reviewerAvatar: String
    var receiverId: String
    var tradeId: String
    var rating: Int
    var comment: String
    var date: Date
}

// MARK: - Sample Data

extension Review {
    static let samples: [Review] = [
        Review(id: "review_priya", reviewerId: "user_maya", reviewerName: "Priya Sharma", reviewerAvatar: "person.circle.fill",
               receiverId: "user_maya", tradeId: "trade_1", rating: 5, comment: "Excellent tutoring session! Very patient and knowledgeable.",
               date: .now.addingTimeInterval(-86400)),

        Review(id: "review_maya", reviewerId: "user_priya", reviewerName: "Maya Chen", reviewerAvatar: "person.circle.fill",
               receiverId: "user_priya", tradeId: "trade_2", rating: 4, comment: "Great home-cooked meal. Would love to trade again!",
               date: .now.addingTimeInterval(-259200)),

        Review(id: "review_arjun", reviewerId: "user_maya", reviewerName: "Arjun Patel", reviewerAvatar: "person.circle.fill",
               receiverId: "user_maya", tradeId: "trade_3", rating: 5, comment: "Super reliable and friendly. Highly recommended!",
               date: .now.addingTimeInterval(-432000)),

        Review(id: "review_rohan", reviewerId: "user_priya", reviewerName: "Rohan Kumar", reviewerAvatar: "person.circle.fill",
               receiverId: "user_priya", tradeId: "trade_4", rating: 3, comment: "Good service overall. Timing could be better.",
               date: .now.addingTimeInterval(-604800)),
    ]
}
