import Foundation
import CoreLocation

struct Listing: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var description: String
    var category: Category
    var type: ListingType
    var credits: Int
    var ownerID: String
    var ownerName: String
    var ownerAvatar: String
    var ownerTrustScore: Double
    var distance: String
    var createdAt: Date
    var iconName: String
    var latitude: Double?
    var longitude: Double?
    var isCompleted: Bool? = false
    var imageUrl: String?

    var shortLocation: String {
        let components = distance.components(separatedBy: ",")
        if components.count >= 2 {
            let lastTwo = components.suffix(2).map { $0.trimmingCharacters(in: .whitespaces) }
            return lastTwo.joined(separator: ", ")
        }
        return distance
    }

    func formattedDistance(from location: CLLocation?) -> String {
        guard let userLoc = location,
              let lat = latitude,
              let lon = longitude else {
            return shortLocation
        }
        let listingLoc = CLLocation(latitude: lat, longitude: lon)
        let distanceInMeters = userLoc.distance(from: listingLoc)
        let km = distanceInMeters / 1000
        return String(format: "%.1f km", km)
    }

    // MARK: Category

    enum Category: String, CaseIterable, Hashable, Codable {
        case all = "All"
        case skills = "Skills"
        case services = "Services"
        case goods = "Goods"
        case education = "Education"
        case wellness = "Wellness"
        case tech = "Tech"

        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .skills: return "lightbulb.fill"
            case .services: return "wrench.and.screwdriver.fill"
            case .goods: return "shippingbox.fill"
            case .education: return "book.fill"
            case .wellness: return "heart.fill"
            case .tech: return "desktopcomputer"
            }
        }
    }

    // MARK: ListingType

    enum ListingType: String, CaseIterable, Hashable, Codable {
        case request = "Request"
        case offer = "Offer"
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            // Case-insensitive matching for robustness with Firestore data
            if rawValue.lowercased() == "request" {
                self = .request
            } else if rawValue.lowercased() == "offer" {
                self = .offer
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath,
                                          debugDescription: "Unknown ListingType: \(rawValue)")
                )
            }
        }
    }
}

// MARK: - Sample Data

extension Listing {
    static let samples: [Listing] = {
        let neighbors = User.sampleNeighbors
        return [
            Listing(id: "listing_math_tutoring", title: "Math Tutoring",
                    description: "Can help with algebra, geometry, and calculus for high school students. 1 hour sessions.",
                    category: .education, type: .offer, credits: 30,
                    ownerID: neighbors[2].id, ownerName: neighbors[2].name,
                    ownerAvatar: neighbors[2].avatarName, ownerTrustScore: neighbors[2].trustScore,
                    distance: "1.2 km", createdAt: .now.addingTimeInterval(-3600),
                    iconName: "function", latitude: 37.7833, longitude: -122.4167),

            Listing(id: "listing_home_cooked_meals", title: "Home-Cooked Meals",
                    description: "Offering fresh, homemade Indian meals. Vegetarian and non-vegetarian options available.",
                    category: .services, type: .offer, credits: 25,
                    ownerID: neighbors[0].id, ownerName: neighbors[0].name,
                    ownerAvatar: neighbors[0].avatarName, ownerTrustScore: neighbors[0].trustScore,
                    distance: "0.3 km", createdAt: .now.addingTimeInterval(-7200),
                    iconName: "fork.knife", latitude: 37.7739, longitude: -122.4312),

            Listing(id: "listing_leaky_faucet", title: "Fix Leaky Faucet",
                    description: "Need help fixing a leaking kitchen faucet. Should be a quick job.",
                    category: .services, type: .request, credits: 20,
                    ownerID: neighbors[1].id, ownerName: neighbors[1].name,
                    ownerAvatar: neighbors[1].avatarName, ownerTrustScore: neighbors[1].trustScore,
                    distance: "0.8 km", createdAt: .now.addingTimeInterval(-1800),
                    iconName: "wrench.fill", latitude: 37.7811, longitude: -122.4218),

            Listing(id: "listing_yoga_session", title: "Yoga Session",
                    description: "Morning yoga session in the park. All levels welcome. Bring your own mat.",
                    category: .wellness, type: .offer, credits: 15,
                    ownerID: neighbors[0].id, ownerName: neighbors[0].name,
                    ownerAvatar: neighbors[0].avatarName, ownerTrustScore: neighbors[0].trustScore,
                    distance: "0.3 km", createdAt: .now.addingTimeInterval(-10800),
                    iconName: "figure.yoga", latitude: 37.7739, longitude: -122.4312),

            Listing(id: "listing_dog_walking", title: "Dog Walking Help",
                    description: "Looking for someone to walk my golden retriever on weekday mornings.",
                    category: .services, type: .request, credits: 15,
                    ownerID: neighbors[3].id, ownerName: neighbors[3].name,
                    ownerAvatar: neighbors[3].avatarName, ownerTrustScore: neighbors[3].trustScore,
                    distance: "0.5 km", createdAt: .now.addingTimeInterval(-5400),
                    iconName: "dog.fill", latitude: 37.7845, longitude: -122.3998),

            Listing(id: "listing_surplus_veggies", title: "Surplus Vegetables",
                    description: "Fresh tomatoes, cucumbers, and peppers from my garden. Organic, no pesticides.",
                    category: .goods, type: .offer, credits: 10,
                    ownerID: neighbors[1].id, ownerName: neighbors[1].name,
                    ownerAvatar: neighbors[1].avatarName, ownerTrustScore: neighbors[1].trustScore,
                    distance: "0.8 km", createdAt: .now.addingTimeInterval(-14400),
                    iconName: "leaf.fill", latitude: 37.7811, longitude: -122.4218),

            Listing(id: "listing_python_tutor", title: "Python Programming",
                    description: "Can teach Python basics and intermediate concepts. Great for beginners.",
                    category: .tech, type: .offer, credits: 35,
                    ownerID: neighbors[2].id, ownerName: neighbors[2].name,
                    ownerAvatar: neighbors[2].avatarName, ownerTrustScore: neighbors[2].trustScore,
                    distance: "1.2 km", createdAt: .now.addingTimeInterval(-18000),
                    iconName: "chevron.left.forwardslash.chevron.right", latitude: 37.7833, longitude: -122.4167),

            Listing(id: "listing_guitar_lessons", title: "Guitar Lessons",
                    description: "Need a guitar teacher for beginner level acoustic guitar. Once a week.",
                    category: .skills, type: .request, credits: 25,
                    ownerID: neighbors[3].id, ownerName: neighbors[3].name,
                    ownerAvatar: neighbors[3].avatarName, ownerTrustScore: neighbors[3].trustScore,
                    distance: "0.5 km", createdAt: .now.addingTimeInterval(-21600),
                    iconName: "guitars.fill", latitude: 37.7845, longitude: -122.3998),
        ]
    }()
}
