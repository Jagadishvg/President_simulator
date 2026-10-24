import Foundation

/// A single choice within a presidential event.
public struct Choice: Codable, Equatable, Identifiable {
    public let id: String              // e.g. "a", "b", "c"
    public let title: String           // short button label
    public let description: String     // what the player would do
    public let tradeoffHint: String    // incomplete, honest hint about trade-offs
    public let isPremium: Bool         // true if a rewarded ad is required to select
    public let premiumToken: String?   // ad-reward token that unlocks this choice
    public let effect: Effect

    public init(id: String, title: String, description: String, tradeoffHint: String,
                isPremium: Bool = false, premiumToken: String? = nil, effect: Effect) {
        self.id = id
        self.title = title
        self.description = description
        self.tradeoffHint = tradeoffHint
        self.isPremium = isPremium
        self.premiumToken = premiumToken
        self.effect = effect
    }
}

/// A presidential event with exactly three choices and optional prerequisites.
public struct PresidentialEvent: Codable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let category: String        // e.g. "economy", "foreign", "crisis"
    public let narrative: String
    public let context: String?        // ties to current conditions / previous decisions
    public let choices: [Choice]       // must be exactly 3

    public var minTurn: Int = 0
    public var maxTurn: Int = Int.max
    public let requiredFlags: [String] = []      // history flags that must be present
    public let excludedFlags: [String] = []      // history flags that must NOT be present
    public let categoryWeight: Double = 1.0      // selection weight relative to category
    public let severity: String = "normal"       // "minor", "normal", "major", "crisis"
    public let isEmergency: Bool = false

    public init(id: String, title: String, category: String, narrative: String,
                context: String? = nil, choices: [Choice], minTurn: Int = 0,
                maxTurn: Int = Int.max, requiredFlags: [String] = [],
                excludedFlags: [String] = [], categoryWeight: Double = 1.0,
                severity: String = "normal", isEmergency: Bool = false) {
        precondition(choices.count == 3, "A PresidentialEvent must have exactly three choices.")
        self.id = id
        self.title = title
        self.category = category
        self.narrative = narrative
        self.context = context
        self.choices = choices
        self.minTurn = minTurn
        self.maxTurn = maxTurn
        self.requiredFlags = requiredFlags
        self.excludedFlags = excludedFlags
        self.categoryWeight = categoryWeight
        self.severity = severity
        self.isEmergency = isEmergency
    }
}

/// Result of processing a player's decision.
public struct DecisionOutcome: Equatable {
    public let event: PresidentialEvent
    public let choice: Choice
    public let narrative: String                 // outcome narrative text
    public let statChanges: [String: Double]     // applied deltas
    public let newsItems: [NewsItem]
    public let delayedEffects: [DelayedEffect]   // newly scheduled effects
    public let historyFlagsAdded: [String]
    public let hiddenRiskTriggered: Bool
    public let followUpEventId: String?
}
