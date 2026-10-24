import Foundation

extension GameState {
    /// Weight of each voter group in the overall approval calculation.
    public var voterGroupWeights: [String: Double] {
        [
            "workingClass": 18,
            "businessOwners": 12,
            "youngVoters": 12,
            "farmers": 10,
            "urbanResidents": 12,
            "ruralResidents": 10,
            "independentVoters": 14,
            "conservativeVoters": 0,   // balanced by liberal
            "liberalVoters": 0,
            "militaryFamilies": 12,
        ]
    }

    /// Overall approval computed from weighted voter-group support + economy + stability.
    public var weightedApproval: Double {
        guard !voterGroups.isEmpty else { return stats.publicApproval.value }
        let totalWeight = voterGroupWeights.values.reduce(0, +)
        guard totalWeight > 0 else { return stats.publicApproval.value }

        var weightedSum = 0.0
        for (group, weight) in voterGroupWeights {
            let support = voterGroups[group] ?? 50
            weightedSum += support * weight
        }
        var approval = weightedSum / totalWeight

        // Economy and social stability modulate approval
        let economyInfluence = (stats.economy.value - 50) * 0.15
        let stabilityInfluence = (stats.socialStability.value - 50) * 0.10
        approval += economyInfluence + stabilityInfluence

        // Scandal penalties
        if historyFlags.contains("scandalDeepens") { approval -= 15 }
        if historyFlags.contains("adminScandal") { approval -= 8 }

        return StatValidator.shared.clamp(approval, min: 0, max: 100)
    }

    /// Congress composition (seat shares 0-100).
    public var congressHouseSeats: Double = 50
    public var congressSenateSeats: Double = 50

    /// Whether the President's party controls Congress (simplified).
    public var congressControlled: Bool {
        congressHouseSupport > 50 && congressSenateSupport > 50
    }

    /// Legislative capital available this turn (0-100).
    public var legislativeCapital: Double {
        let base = (congressHouseSupport + congressSenateSupport) / 2
        let approvalBonus = (weightedApproval - 50) * 0.3
        return StatValidator.shared.clamp(base + approvalBonus, min: 0, max: 100)
    }

    /// Cabinet positions defined for the game.
    public static let cabinetRoles: [String] = [
        "Secretary of State",
        "Secretary of the Treasury",
        "Secretary of Defense",
        "Attorney General",
        "Secretary of Homeland Security",
        "Secretary of Energy",
    ]

    /// Election state.
    public var electionYear: Bool { year == 4 }
    public var midtermYear: Bool { year == 2 }
    public var lastElectionTurn: Int = 0
    public var reElectionWon: Bool? = nil
    public var termLimitsReached: Bool { turn >= termMaxTurns }

    /// Campaign promises made and fulfilled.
    public var campaignPromises: [String: Bool] = [:]   // promiseId -> fulfilled
    public var promisesMadeTurn: Int = 0

    /// Set the campaign promises made at the start of a re-election campaign.
    public mutating func setCampaignPromises(_ ids: [String]) {
        for id in ids {
            campaignPromises[id] = false
        }
        promisesMadeTurn = turn
    }

    /// Mark a campaign promise as fulfilled.
    public mutating func fulfillPromise(_ id: String) {
        campaignPromises[id] = true
    }
}
