import Foundation

struct Trade: Identifiable, Hashable, Codable {
    let id: String
    var listing: Listing
    var requester: User
    var provider: User
    var status: TradeStatus
    var createdAt: Date
    var completedAt: Date?
    var messages: [Message]

    enum TradeStatus: String, CaseIterable, Hashable, Codable {
        case pending = "Pending"
        case active = "Active"
        case providerConfirmed = "Service Provided"
        case requesterConfirmed = "Service Received"
        case completed = "Completed"
        case cancelled = "Cancelled"

        var icon: String {
            switch self {
            case .pending: return "clock.fill"
            case .active: return "arrow.triangle.2.circlepath"
            case .providerConfirmed: return "square.and.arrow.up.fill"
            case .requesterConfirmed: return "square.and.arrow.down.fill"
            case .completed: return "checkmark.circle.fill"
            case .cancelled: return "xmark.circle.fill"
            }
        }
    }
}

// MARK: - Sample Data

extension Trade {
    static let samples: [Trade] = {
        let listings = Listing.samples
        let neighbors = User.sampleNeighbors
        let current = User.current

        return [
            Trade(id: "trade_1", listing: listings[0], requester: current, provider: neighbors[2],
                  status: .active, createdAt: .now.addingTimeInterval(-86400),
                  messages: Message.samplesForTrade("trade_1")),

            Trade(id: "trade_2", listing: listings[1], requester: current, provider: neighbors[0],
                  status: .pending, createdAt: .now.addingTimeInterval(-3600),
                  messages: []),

            Trade(id: "trade_3", listing: listings[3], requester: current, provider: neighbors[0],
                  status: .completed, createdAt: .now.addingTimeInterval(-172800),
                  completedAt: .now.addingTimeInterval(-86400),
                  messages: Message.samplesForTrade("trade_3")),

            Trade(id: "trade_4", listing: listings[4], requester: neighbors[3], provider: current,
                  status: .active, createdAt: .now.addingTimeInterval(-43200),
                  messages: []),

            Trade(id: "trade_5", listing: listings[2], requester: current, provider: neighbors[1],
                  status: .providerConfirmed, createdAt: .now.addingTimeInterval(-10800),
                  messages: []),
        ]
    }()
}
