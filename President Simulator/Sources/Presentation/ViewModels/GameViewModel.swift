import Foundation
import SwiftUI

@MainActor
public class GameViewModel: ObservableObject {
    public let engine: SimulationEngine
    public let saveLoad: SaveLoadManager
    public let contentLoader: ContentLoader
    public let adManager: AdManagerProtocol

    @Published public var state: GameState?
    @Published public var currentEvent: PresidentialEvent?
    @Published public var currentOutcome: DecisionOutcome?
    @Published public var currentTurnResult: TurnResult?
    @Published public var showingOutcome = false
    public var showingLegacy = false
    public var showingTurnSummary = false
    public var showingInauguration = false
    public var isLoading = false
    public var errorMessage: String?
    public var eventsLibrary: [PresidentialEvent] = []

    /// Premium choice tokens granted via rewarded ad this turn, keyed by token.
    private var grantedPremiumTokens: Set<String> = []

    public var isGameOver: Bool { state?.isGameOver ?? false }
    public var isInaugurated: Bool { state?.isInaugurated ?? false }
    public var turn: Int { state?.turn ?? 0 }
    public var year: Int { state?.year ?? 1 }

    public init(adManager: AdManagerProtocol? = nil) {
        self.engine = SimulationEngine()
        self.saveLoad = SaveLoadManager.shared
        self.contentLoader = ContentLoader.shared
        self.adManager = adManager ?? AdManagerStub()
        loadEvents()
    }

    // MARK: - Content

    private func loadEvents() {
        do {
            eventsLibrary = try contentLoader.loadBundledEvents(named: "initial_events")
        } catch {
            eventsLibrary = []
            errorMessage = "Event content not loaded: \(error.localizedDescription)"
        }
    }

    // MARK: - Game lifecycle

    public func startNewPresidency(name: String, party: String, style: String,
                                   difficulty: String, scenario: String) {
        isLoading = true
        var newState = engine.newGameState(presidentName: name, party: party, style: style,
                                           difficulty: difficulty, scenario: scenario)
        newState.isInaugurated = true
        // Set campaign promises based on party/style
        newState.setCampaignPromises(defaultPromises(for: party, style: style))
        state = newState
        currentEvent = nil
        currentOutcome = nil
        currentTurnResult = nil
        showingOutcome = false
        showingLegacy = false
        showingTurnSummary = false
        showingInauguration = true
        isLoading = false
    }

    public func loadGame() throws {
        isLoading = true
        state = try saveLoad.load()
        if let state = state {
            advanceToNextEvent(existing: state)
        }
        isLoading = false
    }

    public func saveGame() throws {
        guard let state = state else { return }
        try saveLoad.save(state)
    }

    public func deleteGame() throws {
        try saveLoad.deleteSave()
        state = nil
        currentEvent = nil
        currentOutcome = nil
        currentTurnResult = nil
        showingOutcome = false
        showingLegacy = false
    }

    public var hasSave: Bool { saveLoad.saveExists() }

    // MARK: - Turn loop

    private func advanceToNextEvent(existing: GameState? = nil) {
        var s = existing ?? state
        guard var state = s else { return }

        let result = engine.advanceTurn(in: &state, from: eventsLibrary)
        currentTurnResult = result
        self.state = state

        if result.isGameOver {
            showingLegacy = true
            return
        }

        // Check achievements after an election
        if result.electionResult != nil {
            _ = checkAchievements()
        }

        currentEvent = result.nextEvent
        currentOutcome = nil
        showingOutcome = false
    }

    // MARK: - Decision

    public func selectChoice(_ choice: Choice) {
        guard var s = state, let event = currentEvent else { return }

        // Premium choices require a rewarded ad before they can be selected.
        if choice.isPremium {
            guard let token = choice.premiumToken else {
                errorMessage = "Premium choice missing ad token."
                return
            }
            guard adManager.hasPremiumChoice(token: token) || grantedPremiumTokens.contains(token) else {
                // Gate: ask view layer to show rewarded ad. We set a pending choice.
                errorMessage = nil
                return
            }
        }

        let outcome = engine.processDecision(choice, for: event, in: &s)
        currentOutcome = outcome
        state = s
        showingOutcome = true

        // Auto-save after each decision
        try? saveGame()
    }

    /// Request to unlock a premium choice via rewarded ad. Calls completion with success.
    public func unlockPremiumChoice(_ choice: Choice, completion: @escaping (Bool) -> Void) {
        guard let token = choice.premiumToken else {
            completion(false)
            return
        }
        adManager.showRewardedAd(for: .premiumChoice) { [weak self] success in
            guard success, let self = self else { completion(false); return }
            self.adManager.grantPremiumChoice(token: token)
            self.grantedPremiumTokens.insert(token)
            completion(true)
        }
    }

    public func isPremiumLocked(_ choice: Choice) -> Bool {
        guard choice.isPremium, let token = choice.premiumToken else { return false }
        return !adManager.hasPremiumChoice(token: token) && !grantedPremiumTokens.contains(token)
    }

    public func continueToNextTurn() {
        currentOutcome = nil
        showingOutcome = false
        advanceToNextEvent()
        let hasConsequences = currentTurnResult?.firedEffects.count ?? 0 > 0
            || currentTurnResult?.electionResult != nil
            || currentTurnResult?.resignations.count ?? 0 > 0
        showingTurnSummary = hasConsequences

        // Interstitial between turns (unless ads removed)
        if !adManager.adsRemoved {
            adManager.showInterstitial(for: .betweenTurns) {}
        }
    }

    // MARK: - Cabinet

    public func reshuffleCabinet(role: String) -> Bool {
        guard var s = state else { return false }
        let result = engine.cabinetManager.reshuffle(role: role, into: &s)
        if result {
            state = s
            try? saveGame()
        }
        return result
    }

    // MARK: - Helpers

    public func statValue(_ key: String) -> Double {
        state?.stats[key]?.value ?? 0
    }

    public func statDelta(_ key: String) -> Double {
        state?.stats[key]?.delta ?? 0
    }

    public func weightedApproval() -> Double {
        state?.weightedApproval ?? 0
    }

    // MARK: - Campaign promises

    private func defaultPromises(for party: String, style: String) -> [String] {
        switch party {
        case "Democratic":
            return ["healthcare_expand", "climate_action", "tax_wealthy"]
        case "Republican":
            return ["tax_cuts", "border_security", "military_strength"]
        default:
            return ["infrastructure", "fiscal_responsibility", "unity"]
        }
    }

    /// Fulfill a campaign promise by ID (called when a related decision is made).
    public func fulfillPromise(_ id: String) {
        guard var s = state else { return }
        s.fulfillPromise(id)
        state = s
    }

    // MARK: - Achievements

    public var unlockedAchievements: [Achievement] {
        AchievementManager.allAchievements.filter { $0.unlocked }
    }

    public func checkAchievements() -> [Achievement] {
        guard let s = state else { return [] }
        return AchievementManager.check(state: s, engine: engine)
    }
}
