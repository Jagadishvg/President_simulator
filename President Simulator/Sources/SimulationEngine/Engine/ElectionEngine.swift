import Foundation

/// Election calculation based on approval, economy, groups, scandals, promises.
public final class ElectionEngine {
    private let validator = StatValidator.shared

    public func runMidtermElection(state: inout GameState) -> ElectionResult {
        let approval = state.weightedApproval
        let economy = state.stats.economy.value
        let stability = state.stats.socialStability.value
        let scandalPenalty = state.historyFlags.contains("scandalDeepens") ? 12 :
            state.historyFlags.contains("adminScandal") ? 6 : 0

        // Midterms typically swing against the incumbent party.
        let swing = (50 - approval) * 0.4 + (50 - economy) * 0.2 + (50 - stability) * 0.2 - scandalPenalty * 0.5
        let houseChange = validator.clamp(Int(swing.rounded()), min: -30, max: 30)
        let senateChange = validator.clamp(Int(swing * 0.6).rounded(), min: -15, max: 15)

        state.congressHouseSupport = validator.clamp(state.congressHouseSupport + Double(houseChange), min: 0, max: 100)
        state.congressSenateSupport = validator.clamp(state.congressSenateSupport + Double(senateChange), min: 0, max: 100)

        let result = ElectionResult(
            type: "midterm",
            turn: state.turn,
            approval: approval,
            houseSupport: state.congressHouseSupport,
            senateSupport: state.congressSenateSupport,
            swing: swing,
            description: midtermDescription(swing: swing, approval: approval)
        )
        state.news.append(NewsItem(turn: state.turn, headline: result.headline, summary: result.description,
                                   category: "politics", tone: result.tone))
        state.lastElectionTurn = state.turn
        return result
    }

    public func runPresidentialElection(state: inout GameState) -> ElectionResult {
        let approval = state.weightedApproval
        let economy = state.stats.economy.value
        let security = state.stats.nationalSecurity.value
        let diplomacy = state.stats.internationalReputation.value
        let stability = state.stats.socialStability.value
        let integrity = cabinetIntegrity(state: state)

        let scandalPenalty = state.historyFlags.contains("scandalDeepens") ? 18 :
            state.historyFlags.contains("adminScandal") ? 10 : 0
        let promiseBonus = promiseFulfillmentBonus(state: state)

        let score = (approval * 0.30) + (economy * 0.20) + (security * 0.12)
            + (diplomacy * 0.10) + (stability * 0.12) + (integrity * 0.08)
            + promiseBonus - scandalPenalty

        let won = score > 50
        state.reElectionWon = won

        let margin = validator.clamp(score - 50, min: -40, max: 40)
        let result = ElectionResult(
            type: "presidential",
            turn: state.turn,
            approval: approval,
            houseSupport: state.congressHouseSupport,
            senateSupport: state.congressSenateSupport,
            swing: margin,
            description: presidentialDescription(won: won, score: score, margin: margin),
            won: won
        )
        state.news.append(NewsItem(turn: state.turn, headline: result.headline, summary: result.description,
                                   category: "politics", tone: result.tone))
        state.lastElectionTurn = state.turn

        if !won {
            state.isGameOver = true
            state.gameOverReason = "electionLost"
        }
        return result
    }

    private func cabinetIntegrity(state: GameState) -> Double {
        guard !state.cabinet.isEmpty else { return 50 }
        let avg = state.cabinet.values.reduce(0) { $0 + $1.integrity } / Double(state.cabinet.count)
        return validator.clamp(avg, min: 0, max: 100)
    }

    private func promiseFulfillmentBonus(state: GameState) -> Double {
        guard !state.campaignPromises.isEmpty else { return 0 }
        let fulfilled = state.campaignPromises.values.filter { $0 }.count
        return Double(fulfilled) / Double(state.campaignPromises.count) * 10
    }

    private func midtermDescription(swing: Double, approval: Double) -> String {
        if swing > 5 {
            return "Your party gains ground in Congress. Voters reward steady leadership."
        } else if swing > -5 {
            return "Congress remains closely divided. The midterm is a wash."
        } else if swing > -15 {
            return "Opposition makes gains. Your legislative agenda faces headwinds."
        } else {
            return "A wave election against your party. Congress flips to the opposition."
        }
    }

    private func presidentialDescription(won: Bool, score: Double, margin: Double) -> String {
        if won {
            if margin > 15 {
                return "Landslide re-election victory. The country endorses your leadership."
            } else if margin > 5 {
                return "Re-elected. A clear mandate to continue your agenda."
            } else {
                return "Narrow re-election victory. The nation remains divided."
            }
        } else {
            if margin < -15 {
                return "Decisive defeat. Voters reject your presidency."
            } else if margin < -5 {
                return "You lose re-election. Your term ends in January."
            } else {
                return "A narrow loss. The opposition takes the White House."
            }
        }
    }
}

public struct ElectionResult: Codable, Equatable {
    public let type: String
    public let turn: Int
    public let approval: Double
    public let houseSupport: Double
    public let senateSupport: Double
    public let swing: Double
    public let description: String
    public var won: Bool = false

    public var headline: String {
        switch type {
        case "midterm":
            return swing > 0 ? "Midterms: Gains for the President's Party"
                : (swing < -10 ? "Midterm Wave Against the Administration" : "Midterms: Divided Congress")
        case "presidential":
            return won ? "Re-Election Victory" : "Defeat in the Presidential Election"
        default: return "Election Results"
        }
    }

    public var tone: String {
        if type == "presidential" { return won ? "positive" : "negative" }
        return swing > 0 ? "positive" : (swing < -5 ? "negative" : "neutral")
    }
}
