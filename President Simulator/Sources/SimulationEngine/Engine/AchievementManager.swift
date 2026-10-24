import Foundation

/// Achievements and unlockable content.
public struct Achievement: Codable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let icon: String
    public var unlocked: Bool = false
    public var unlockedAt: Int? = nil

    public init(id: String, title: String, description: String, icon: String) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
    }
}

public final class AchievementManager {
    public static let allAchievements: [Achievement] = [
        Achievement(id: "first_turn", title: "First Decision", description: "Make your first presidential decision.", icon: "1.circle"),
        Achievement(id: "survivor", title: "Survivor", description: "Complete a full four-year term.", icon: "calendar"),
        Achievement(id: "economist", title: "Economist", description: "End a term with economy above 70.", icon: "chart.line.up"),
        Achievement(id: "peacemaker", title: "Peacemaker", description: "End with international reputation above 75.", icon: "dove"),
        Achievement(id: "uniter", title: "The Uniter", description: "End with social stability above 75.", icon: "hand.raised"),
        Achievement(id: "landslide", title: "Landslide", description: "Win re-election with over 60% approval.", icon: "star.fill"),
        Achievement(id: "clean_hands", title: "Clean Hands", description: "Complete a term with no scandals.", icon: "checkmark.shield"),
        Achievement(id: "crisis_manager", title: "Crisis Manager", description: "Successfully navigate 3 emergency events.", icon: "exclamationmark.triangle"),
        Achievement(id: "builder", title: "Builder", description: "Pass infrastructure and clean energy bills.", icon: "building.2"),
        Achievement(id: "diplomat", title: "Diplomat", description: "Maintain 5+ allied nations.", icon: "globe"),
        Achievement(id: "fiscal_conservative", title: "Fiscal Conservative", description: "End with national debt below 30.", icon: "dollarsign.circle"),
        Achievement(id: "populist", title: "Populist", description: "End with working-class support above 70.", icon: "person.2"),
        Achievement(id: "globalist", title: "Globalist", description: "Improve relations with all major powers.", icon: "network"),
        Achievement(id: "iron_fist", title: "Iron Fist", description: "Deploy military force in a foreign crisis.", icon: "shield.fill"),
        Achievement(id: "statesman", title: "Statesman", description: "Achieve legacy score over 80.", icon: "medal.fill"),
    ]

    public static func check(state: GameState, engine: SimulationEngine) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        for achievement in allAchievements where !achievement.unlocked {
            let unlocked = evaluate(achievement.id, state: state, engine: engine)
            if unlocked {
                newlyUnlocked.append(Achievement(id: achievement.id, title: achievement.title,
                                                 description: achievement.description, icon: achievement.icon, unlocked: true, unlockedAt: state.turn))
            }
        }
        return newlyUnlocked
    }

    private static func evaluate(_ id: String, state: GameState, engine: SimulationEngine) -> Bool {
        switch id {
        case "first_turn": return state.turn >= 1
        case "survivor": return state.turn >= state.termMaxTurns
        case "economist": return state.stats.economy.value > 70
        case "peacemaker": return state.stats.internationalReputation.value > 75
        case "uniter": return state.stats.socialStability.value > 75
        case "landslide": return state.reElectionWon == true && state.weightedApproval > 60
        case "clean_hands": return !state.historyFlags.contains("adminScandal") && !state.historyFlags.contains("scandalDeepens")
        case "crisis_manager": return state.history.filter { $0.eventId.contains("cyberattack") || $0.eventId.contains("natural_disaster") }.count >= 3
        case "builder": return state.historyFlags.contains("infrastructureInvestment") && state.historyFlags.contains("climateInvestment")
        case "diplomat": return InternationalManager.allies(state: state).count >= 5
        case "fiscal_conservative": return state.stats.nationalDebt.value < 30
        case "populist": return (state.voterGroups["workingClass"] ?? 0) > 70
        case "globalist": return InternationalManager.allies(state: state).count >= InternationalManager.countries.count / 2
        case "iron_fist": return state.historyFlags.contains("militaryIntervention")
        case "statesman": return engine.computeLegacy(state: state).score > 80
        default: return false
        }
    }
}
