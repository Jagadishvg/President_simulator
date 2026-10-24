import Foundation

/// Cabinet management: appointments, attributes, recommendations, resignations, scandals.
public final class CabinetManager {
    private let validator = StatValidator.shared
    private let random: SeededRandom

    public init(random: SeededRandom) {
        self.random = random
    }

    /// Assign cabinet members with randomized but balanced attributes.
    public func appointCabinet(into state: inout GameState, style: String) {
        let roleTemplates: [String: (competence: Double, loyalty: Double, integrity: Double, ambition: Double, alignment: Double)] = [
            "Secretary of State": (75, 70, 75, 50, 70),
            "Secretary of the Treasury": (80, 65, 70, 55, 65),
            "Secretary of Defense": (70, 75, 70, 60, 70),
            "Attorney General": (65, 80, 85, 45, 75),
            "Secretary of Homeland Security": (70, 70, 70, 55, 70),
            "Secretary of Energy": (65, 65, 70, 50, 65),
        ]

        for role in GameState.cabinetRoles {
            let t = roleTemplates[role] ?? (60, 60, 60, 50, 60)
            let variance = { () -> Double in
                Double(random.nextInt(lower: -10, upper: 10))
            }
            let name = randomCabinetName()
            state.cabinet[role] = CabinetMember(
                role: role,
                name: name,
                competence: validator.clamp(t.competence + variance(), min: 40, max: 95),
                loyalty: validator.clamp(t.loyalty + variance(), min: 40, max: 95),
                integrity: validator.clamp(t.integrity + variance(), min: 40, max: 95),
                ambition: validator.clamp(t.ambition + variance(), min: 30, max: 80),
                policyAlignment: validator.clamp(t.alignment + variance(), min: 40, max: 90)
            )
        }
    }

    /// Reshuffle: replace a cabinet member. Costs political capital.
    public func reshuffle(role: String, into state: inout GameState) -> Bool {
        guard state.cabinet[role] != nil else { return false }
        let old = state.cabinet[role]!
        let name = randomCabinetName()
        state.cabinet[role] = CabinetMember(
            role: role, name: name,
            competence: Double(random.nextInt(lower: 45, upper: 90)),
            loyalty: Double(random.nextInt(lower: 50, upper: 90)),
            integrity: Double(random.nextInt(lower: 50, upper: 90)),
            ambition: Double(random.nextInt(lower: 35, upper: 75)),
            policyAlignment: Double(random.nextInt(lower: 50, upper: 85))
        )
        // Reshuffling angers the departed minister and costs a little support
        state.congressHouseSupport = validator.clamp(state.congressHouseSupport - 3, min: 0, max: 100)
        state.congressSenateSupport = validator.clamp(state.congressSenateSupport - 3, min: 0, max: 100)
        state.stats.adjust("socialStability", by: -2)
        state.historyFlags.insert("cabinetReshuffle_\(role)")
        return true
    }

    /// Check for voluntary resignations (low loyalty + low alignment + random chance).
    public func checkResignations(into state: inout GameState) -> [String] {
        var resigned: [String] = []
        for (role, member) in state.cabinet where !member.isResigned {
            let risk = (100 - member.loyalty) * 0.003 + (100 - member.policyAlignment) * 0.002
            if random.bool(probability: risk) {
                state.cabinet[role] = CabinetMember(
                    role: role, name: member.name,
                    competence: member.competence, loyalty: member.loyalty,
                    integrity: member.integrity, ambition: member.ambition,
                    policyAlignment: member.policyAlignment, isResigned: true
                )
                resigned.append(role)
                state.stats.adjust("publicApproval", by: -4)
                state.stats.adjust("congressSupport", by: -3)
                state.news.append(NewsItem(turn: state.turn, headline: "\(member.name) Resigns as \(role)",
                                           summary: "The \(role) steps down amid internal tensions.",
                                           category: "politics", tone: "negative"))
            }
        }
        return resigned
    }

    /// Get adviser recommendation for an event choice (simple heuristic).
    public func recommendation(for choiceId: String, event: PresidentialEvent, state: GameState) -> String? {
        // Role-based guidance
        let roleGuidance: [String: [String: String]] = [
            "Secretary of State": [
                "a": "Escalation risks conflict but shows strength.",
                "b": "Diplomacy preserves alliances.",
                "c": "Measured response avoids overcommitment.",
            ],
            "Secretary of the Treasury": [
                "a": "Tight money fights inflation but slows growth.",
                "b": "Relief helps households but widens the deficit.",
                "c": "Spending boosts demand but risks overheating.",
            ],
        ]
        guard let roleGuides = roleGuidance.first(where: { state.cabinet.keys.contains($0.key) })?.value else {
            return nil
        }
        return roleGuides[choiceId]
    }

    private func randomCabinetName() -> String {
        let first = ["James", "Maria", "David", "Sarah", "Robert", "Jennifer", "Michael", "Lisa",
                     "Christopher", "Amanda", "Daniel", "Michelle", "Matthew", "Elizabeth"]
        let last = ["Anderson", "Bennett", "Coleman", "Davis", "Ellis", "Foster", "Grayson",
                    "Hayes", "Irwin", "Jenkins", "Keller", "Lawson", "Myers", "Nelson"]
        return "\(first.randomElement() ?? "Alex") \(last.randomElement() ?? "Morgan")"
    }
}
