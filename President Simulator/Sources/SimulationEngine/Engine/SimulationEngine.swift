import Foundation

/// The core simulation engine. Pure Swift — no UIKit/SwiftUI dependencies.
/// All gameplay calculations happen here; it is fully testable with XCTest.
public final class SimulationEngine {
    public let random: SeededRandom
    public let validator: StatValidator
    public let scheduler: ConsequenceScheduler
    public let cabinetManager: CabinetManager
    public let internationalManager: InternationalManager
    public let electionEngine: ElectionEngine

    public init(seed: UInt64? = nil) {
        self.random = SeededRandom(seed: seed ?? UInt64(Date().timeIntervalSince1970 * 1000))
        self.validator = StatValidator.shared
        self.scheduler = ConsequenceScheduler(validator: validator)
        self.cabinetManager = CabinetManager(random: random)
        self.internationalManager = InternationalManager()
        self.electionEngine = ElectionEngine()
    }

    // MARK: - Game lifecycle

    /// Create a fresh game state for a new presidency.
    public func newGameState(presidentName: String, party: String, style: String,
                             difficulty: String, scenario: String = "default") -> GameState {
        var state = GameState()
        state.presidentName = presidentName
        state.presidentParty = party
        state.leadershipStyle = style
        state.difficulty = difficulty
        state.unlockedScenarios.insert(scenario)
        applyScenario(startingScenario: scenario, into: &state)
        initializeVoterGroups(into: &state)
        cabinetManager.appointCabinet(into: &state, style: style)
        internationalManager.initializeRelations(into: &state)
        state.lastElectionTurn = 0
        return state
    }

    private func applyScenario(startingScenario: String, into state: inout GameState) {
        let diff = DifficultySettings.for(state.difficulty)
        switch startingScenario {
        case "recession":
            state.stats.adjust("economy", by: -25)
            state.stats.adjust("unemployment", by: 15)
            state.stats.adjust("publicApproval", by: -10)
            state.stats.adjust("treasuryBudget", by: -30)
        case "internationalCrisis":
            state.stats.adjust("internationalReputation", by: -15)
            state.stats.adjust("nationalSecurity", by: -10)
            state.stats.adjust("publicApproval", by: -5)
        case "scandal":
            state.stats.adjust("publicApproval", by: -15)
            state.stats.adjust("congressSupport", by: -10)
            state.stats.adjust("socialStability", by: -10)
            state.historyFlags.insert("adminScandal")
        case "dividedCongress":
            state.congressHouseSupport = 35
            state.congressSenateSupport = 40
            state.stats.adjust("congressSupport", by: -20)
        case "boomingEconomy":
            state.stats.adjust("economy", by: 20)
            state.stats.adjust("unemployment", by: -10)
            state.stats.adjust("publicApproval", by: 10)
            state.stats.adjust("treasuryBudget", by: 25)
        case "climateEmergency":
            state.stats.adjust("socialStability", by: -10)
            state.stats.adjust("economy", by: -10)
            state.historyFlags.insert("climateEmergencyActive")
        default:
            break
        }
        // Apply difficulty congress penalty
        if diff.congressPenalty != 0 {
            state.congressHouseSupport = validator.clamp(state.congressHouseSupport + diff.congressPenalty, min: 0, max: 100)
            state.congressSenateSupport = validator.clamp(state.congressSenateSupport + diff.congressPenalty, min: 0, max: 100)
            state.stats.adjust("congressSupport", by: diff.congressPenalty)
        }
        validator.sanitize(&state)
    }

    private func initializeVoterGroups(into state: inout GameState) {
        let groups: [String: Double] = [
            "workingClass": 55,
            "businessOwners": 50,
            "youngVoters": 50,
            "farmers": 55,
            "urbanResidents": 55,
            "ruralResidents": 55,
            "independentVoters": 50,
            "conservativeVoters": 50,
            "liberalVoters": 50,
            "militaryFamilies": 60,
        ]
        state.voterGroups = groups
    }

    // MARK: - Turn advancement

    /// Advance one turn: fire due effects, apply decay, check elections, select next event.
    public func advanceTurn(in state: inout GameState, from library: [PresidentialEvent]) -> TurnResult {
        // Fire due delayed consequences first
        let fired = fireDueEffects(in: &state)

        // Apply per-turn approval decay based on difficulty
        let decay = difficulty.approvalDecayPerTurn
        if decay > 0 {
            state.stats.adjust("publicApproval", by: -decay)
            // Small stability drift
            state.stats.adjust("socialStability", by: -decay * 0.5)
        }

        // Increment turn
        state.advanceTurn()

        // Election checks
        var electionResult: ElectionResult?
        if state.year == 2 && state.turn > state.lastElectionTurn && state.midtermYear {
            electionResult = electionEngine.runMidtermElection(state: &state)
        } else if state.year == 4 && state.turn > state.lastElectionTurn && state.electionYear {
            electionResult = electionEngine.runPresidentialElection(state: &state)
        }

        // Check cabinet resignations
        let resignations = cabinetManager.checkResignations(into: &state)

        // Select next event if game not over
        var nextEvent: PresidentialEvent?
        if !state.isGameOver {
            nextEvent = selectEvent(from: library, state: state)
            if state.recentEventIds.contains(nextEvent?.id ?? "") == false {
                if let eid = nextEvent?.id { state.recentEventIds.append(eid) }
            }
        }

        validator.sanitize(&state)

        return TurnResult(firedEffects: fired, electionResult: electionResult,
                          resignations: resignations, nextEvent: nextEvent,
                          isGameOver: state.isGameOver, turn: state.turn, year: state.year)
    }

    // MARK: - Event selection

    public func selectEvent(from library: [PresidentialEvent], state: GameState) -> PresidentialEvent? {
        let diff = DifficultySettings.for(state.difficulty)
        let eligible = library.filter { event in
            guard event.minTurn <= state.turn && state.turn <= event.maxTurn else { return false }
            guard validator.eventPrerequisitesValid(event, flags: state.historyFlags) else { return false }
            guard !state.recentEventIds.contains(event.id) else { return false }
            // Emergency events more likely on higher difficulty / low stability
            if event.isEmergency {
                let base = state.stats.socialStability.value < 40 ? 2.0 : 1.0
                return random.bool(probability: 0.15 * base * diff.crisisFrequency)
            }
            return true
        }
        guard !eligible.isEmpty else { return nil }

        var totalWeight = 0.0
        var weighted: [(PresidentialEvent, Double)] = []
        for event in eligible {
            let w = categoryWeight(for: event.category, state: state) * event.categoryWeight
            weighted.append((event, w))
            totalWeight += w
        }
        guard totalWeight > 0 else { return eligible.first! }

        let threshold = random.nextDouble() * totalWeight
        var accumulator = 0.0
        for (event, w) in weighted {
            accumulator += w
            if threshold <= accumulator {
                return event
            }
        }
        return eligible.last!
    }

    private func categoryWeight(for category: String, state: GameState) -> Double {
        switch category {
        case "economy":
            return state.stats.economy.value < 40 ? 2.0 : (state.stats.inflation.value > 60 ? 1.8 : 1.0)
        case "foreign":
            let avgRel = state.internationalRelations.values.isEmpty ? 0 :
                state.internationalRelations.values.reduce(0, +) / Double(state.internationalRelations.count)
            return avgRel < 20 ? 1.6 : 1.0
        case "crisis":
            return state.stats.socialStability.value < 35 ? 1.7 : 1.0
        default:
            return 1.0
        }
    }

    // MARK: - Decision processing

    public func processDecision(_ choice: Choice, for event: PresidentialEvent, in state: inout GameState) -> DecisionOutcome {
        let turn = state.turn
        let diff = DifficultySettings.for(state.difficulty)
        var statChanges: [String: Double] = [:]

        // Apply immediate stat changes with difficulty modifier
        for (key, delta) in choice.effect.statChanges {
            let adjustedDelta = delta > 0 ? delta * diff.positiveImpactMultiplier : delta * diff.negativeImpactMultiplier
            let before = state.stats[key]?.value ?? 0
            state.stats.adjust(key, by: adjustedDelta)
            let after = state.stats[key]?.value ?? 0
            statChanges[key] = after - before
        }

        // Budget
        if choice.effect.budgetDelta != 0 {
            let adjusted = choice.effect.budgetDelta *
                (choice.effect.budgetDelta > 0 ? diff.positiveImpactMultiplier : diff.negativeImpactMultiplier)
            let before = state.stats.treasuryBudget.value
            state.stats.adjust("treasuryBudget", by: adjusted)
            let after = state.stats.treasuryBudget.value
            statChanges["treasuryBudget"] = after - before
        }

        // Congress support
        if choice.effect.congressDelta != 0 {
            let adjusted = choice.effect.congressDelta *
                (choice.effect.congressDelta > 0 ? diff.positiveImpactMultiplier : diff.negativeImpactMultiplier)
            state.congressHouseSupport = validator.clamp(state.congressHouseSupport + adjusted, min: 0, max: 100)
            state.congressSenateSupport = validator.clamp(state.congressSenateSupport + adjusted, min: 0, max: 100)
            statChanges["congressSupport"] = adjusted
        }

        // International reputation
        if choice.effect.internationalReputationDelta != 0 {
            let adjusted = choice.effect.internationalReputationDelta *
                (choice.effect.internationalReputationDelta > 0 ? diff.positiveImpactMultiplier : diff.negativeImpactMultiplier)
            state.stats.adjust("internationalReputation", by: adjusted)
        }

        // Voter group changes
        for (group, delta) in choice.effect.voterGroupChanges {
            let adjusted = delta *
                (delta > 0 ? diff.positiveImpactMultiplier : diff.negativeImpactMultiplier)
            let before = state.voterGroups[group] ?? 50
            let after = validator.clamp(before + adjusted, min: 0, max: 100)
            state.voterGroups[group] = after
        }

        // History flags
        var flagsAdded: [String] = []
        for flag in choice.effect.historyFlags {
            if state.historyFlags.insert(flag).inserted {
                flagsAdded.append(flag)
            }
        }
        for flag in choice.effect.historyFlagsToRemove {
            state.historyFlags.remove(flag)
        }

        // Hidden risk
        var hiddenRiskTriggered = false
        if choice.effect.hiddenRiskProbability > 0 && random.bool(probability: choice.effect.hiddenRiskProbability) {
            if let flag = choice.effect.hiddenRiskFlag {
                state.historyFlags.insert(flag)
                flagsAdded.append(flag)
                hiddenRiskTriggered = true
            }
        }

        // Record decision
        let record = DecisionRecord(turn: turn, eventId: event.id, choiceId: choice.id,
                                    choiceTitle: choice.title, narrative: event.narrative,
                                    statChanges: statChanges, historyFlags: flagsAdded)
        state.history.append(record)

        // News items
        var newsItems: [NewsItem] = []
        if let headline = choice.effect.newsHeadline {
            newsItems.append(NewsItem(turn: turn, headline: headline, summary: choice.effect.newsSummary ?? "",
                                      category: choice.effect.newsCategory, tone: choice.effect.newsTone,
                                      relatedEventId: event.id))
        }

        // Delayed / follow-up effects
        var delayedEffects: [DelayedEffect] = []
        if let followUp = choice.effect.followUpEventId, choice.effect.followUpDelay > 0 {
            let flag = "followup_\(followUp)_\(turn)"
            scheduler.scheduleFollowUpFlag(into: &state, flag: flag, delay: choice.effect.followUpDelay,
                                           sourceEventId: event.id, description: "Pending consequence: \(followUp)")
            delayedEffects.append(DelayedEffect(triggerTurn: turn + choice.effect.followUpDelay,
                                                effect: choice.effect, sourceEventId: event.id,
                                                description: "Pending consequence: \(followUp)"))
        }

        validator.sanitize(&state)

        // Advance turn after processing (decision consumed one turn)
        state.advanceTurn()
        if state.recentEventIds.contains(event.id) == false {
            state.recentEventIds.append(event.id)
        }

        let outcomeNarrative = buildOutcomeNarrative(event: event, choice: choice, state: state)

        return DecisionOutcome(event: event, choice: choice, narrative: outcomeNarrative,
                               statChanges: statChanges, newsItems: newsItems,
                               delayedEffects: delayedEffects,
                               historyFlagsAdded: flagsAdded,
                               hiddenRiskTriggered: hiddenRiskTriggered,
                               followUpEventId: choice.effect.followUpEventId)
    }

    /// Fire all due delayed effects in the current state.
    public func fireDueEffects(in state: inout GameState) -> [DelayedEffect] {
        let due = scheduler.dueEffects(in: state)
        for var effect in due {
            for (key, delta) in effect.effect.statChanges {
                state.stats.adjust(key, by: delta)
            }
            if effect.effect.budgetDelta != 0 {
                state.stats.adjust("treasuryBudget", by: effect.effect.budgetDelta)
            }
            for (group, delta) in effect.effect.voterGroupChanges {
                let before = state.voterGroups[group] ?? 50
                state.voterGroups[group] = validator.clamp(before + delta, min: 0, max: 100)
            }
            for flag in effect.effect.historyFlags {
                state.historyFlags.insert(flag)
            }
            scheduler.markFired(&effect)
        }
        scheduler.pruneFired(into: &state)
        validator.sanitize(&state)
        return due
    }

    // MARK: - Legacy / end-of-term

    public func computeLegacy(state: GameState) -> LegacyReport {
        let avgEconomy = state.stats.economy.value
        let avgApproval = state.weightedApproval
        let security = state.stats.nationalSecurity.value
        let diplomacy = state.stats.internationalReputation.value
        let stability = state.stats.socialStability.value
        let integrity = cabinetIntegrity(state: state)
        let promisesKept = promiseFulfillmentPercent(state: state)

        let score = (avgEconomy * 0.20) + (avgApproval * 0.20) + (security * 0.15)
            + (diplomacy * 0.15) + (stability * 0.15) + (integrity * 0.10) + (promisesKept * 0.05)

        let title: String
        switch score {
        case 80...: title = "The People's President"
        case 70..<80: title = "The Economic Reformer"
        case 60..<70: title = "The Crisis Manager"
        case 50..<60: title = "The Political Survivor"
        case 40..<50: title = "The Divisive President"
        default: title = "The Failed Presidency"
        }

        return LegacyReport(score: score, title: title, economy: avgEconomy,
                            publicWelfare: avgApproval, nationalSecurity: security,
                            diplomaticSuccess: diplomacy, governmentIntegrity: integrity,
                            politicalStability: stability, promisesKept: promisesKept,
                            totalDecisions: state.totalDecisions)
    }

    private func cabinetIntegrity(state: GameState) -> Double {
        guard !state.cabinet.isEmpty else { return 50 }
        let avg = state.cabinet.values.reduce(0) { $0 + $1.integrity } / Double(state.cabinet.count)
        let scandalPenalty = state.historyFlags.contains("adminScandal") ? 20 : 0
        return validator.clamp(avg - scandalPenalty, min: 0, max: 100)
    }

    private func promiseFulfillmentPercent(state: GameState) -> Double {
        guard !state.campaignPromises.isEmpty else { return 50 }
        let fulfilled = state.campaignPromises.values.filter { $0 }.count
        return Double(fulfilled) / Double(state.campaignPromises.count) * 100
    }

    // MARK: - Helpers

    private func buildOutcomeNarrative(event: PresidentialEvent, choice: Choice, state: GameState) -> String {
        let direction: String
        let avgChange = choice.effect.statChanges.values.reduce(0, +) / Double(max(choice.effect.statChanges.count, 1))
        if avgChange > 5 { direction = "a positive shift" }
        else if avgChange < -5 { direction = "a difficult shift" }
        else { direction = "a measured outcome" }

        return "You chose: \(choice.title). The decision produced \(direction). \(choice.effect.newsSummary ?? "The country absorbs the impact.")"
    }
}

/// Result of advancing one turn.
public struct TurnResult: Equatable {
    public let firedEffects: [DelayedEffect]
    public let electionResult: ElectionResult?
    public let resignations: [String]
    public let nextEvent: PresidentialEvent?
    public let isGameOver: Bool
    public let turn: Int
    public let year: Int
}
