import XCTest
@testable import SimulationEngine

final class SimulationEngineTests: XCTestCase {

    func testDeterministicOutcomeWithSameSeed() {
        let engineA = SimulationEngine(seed: 12345)
        let engineB = SimulationEngine(seed: 12345)

        var stateA = engineA.newGameState(presidentName: "Test", party: "Independent",
                                          style: "Pragmatic", difficulty: "Normal")
        var stateB = engineB.newGameState(presidentName: "Test", party: "Independent",
                                          style: "Pragmatic", difficulty: "Normal")

        let event = PresidentialEvent(
            id: "test_event", title: "Test", category: "economy", narrative: "narrative",
            choices: [
                Choice(id: "a", title: "A", description: "desc A", tradeoffHint: "hint A",
                       effect: Effect(statChanges: ["publicApproval": 10, "economy": -5])),
                Choice(id: "b", title: "B", description: "desc B", tradeoffHint: "hint B",
                       effect: Effect(statChanges: ["publicApproval": -5, "economy": 10])),
                Choice(id: "c", title: "C", description: "desc C", tradeoffHint: "hint C",
                       effect: Effect(statChanges: [:]))
            ]
        )

        let outcomeA = engineA.processDecision(event.choices[0], for: event, in: &stateA)
        let outcomeB = engineB.processDecision(event.choices[0], for: event, in: &stateB)

        XCTAssertEqual(stateA.stats.publicApproval.value, stateB.stats.publicApproval.value)
        XCTAssertEqual(stateA.stats.economy.value, stateB.stats.economy.value)
        XCTAssertEqual(outcomeA.statChanges, outcomeB.statChanges)
    }

    func testStatsAreClampedToValidRange() {
        var engine = SimulationEngine(seed: 1)
        var state = engine.newGameState(presidentName: "T", party: "I", style: "P", difficulty: "N")

        // Push public approval far above max.
        state.stats.adjust("publicApproval", by: 1000)
        engine.validator.sanitize(&state)
        XCTAssertEqual(state.stats.publicApproval.value, 100)

        // Push below min.
        state.stats.adjust("publicApproval", by: -1000)
        engine.validator.sanitize(&state)
        XCTAssertEqual(state.stats.publicApproval.value, 0)
    }

    func testDelayedEffectFiresAtTriggerTurn() {
        var engine = SimulationEngine(seed: 1)
        var state = engine.newGameState(presidentName: "T", party: "I", style: "P", difficulty: "N")

        let initialEconomy = state.stats.economy.value
        engine.scheduler.schedule(into: &state, effect: Effect(statChanges: ["economy": 20]),
                                  sourceEventId: "ev", delay: 3, description: "test delay")

        // Not yet due.
        let fired1 = engine.fireDueEffects(in: &state)
        XCTAssertEqual(fired1.count, 0)
        XCTAssertEqual(state.stats.economy.value, initialEconomy)

        // Advance to trigger turn.
        state.turn = 3
        let fired2 = engine.fireDueEffects(in: &state)
        XCTAssertEqual(fired2.count, 1)
        XCTAssertEqual(state.stats.economy.value, initialEconomy + 20)
    }

    func testVoterGroupClamped() {
        var engine = SimulationEngine(seed: 1)
        var state = engine.newGameState(presidentName: "T", party: "I", style: "P", difficulty: "N")
        state.voterGroups["workingClass", default: 50] = 200
        engine.validator.sanitize(&state)
        XCTAssertEqual(state.voterGroups["workingClass"], 100)

        state.voterGroups["workingClass", default: 50] = -50
        engine.validator.sanitize(&state)
        XCTAssertEqual(state.voterGroups["workingClass"], 0)
    }

    func testEventPrerequisitesBlockedByMissingFlag() {
        let engine = SimulationEngine(seed: 1)
        var state = GameState()
        let event = PresidentialEvent(
            id: "req_event", title: "Req", category: "politics", narrative: "n",
            choices: [Choice(id: "a", title: "A", description: "d", tradeoffHint: "h", effect: Effect()),
                      Choice(id: "b", title: "B", description: "d", tradeoffHint: "h", effect: Effect()),
                      Choice(id: "c", title: "C", description: "d", tradeoffHint: "h", effect: Effect())],
            requiredFlags: ["some_flag"]
        )
        XCTAssertFalse(engine.validator.eventPrerequisitesValid(event, flags: state.historyFlags))
        state.historyFlags.insert("some_flag")
        XCTAssertTrue(engine.validator.eventPrerequisitesValid(event, flags: state.historyFlags))
    }

    func testLegacyReportComputes() {
        let engine = SimulationEngine(seed: 1)
        var state = GameState()
        state.stats.publicApproval = NationalStat(key: "publicApproval", value: 80, previousValue: 80)
        state.stats.economy = NationalStat(key: "economy", value: 75, previousValue: 75)
        state.stats.nationalSecurity = NationalStat(key: "nationalSecurity", value: 70, previousValue: 70)
        state.stats.internationalReputation = NationalStat(key: "internationalReputation", value: 65, previousValue: 65)
        state.stats.socialStability = NationalStat(key: "socialStability", value: 60, previousValue: 60)
        let report = engine.computeLegacy(state: state)
        XCTAssertGreaterThan(report.score, 0)
        XCTAssertFalse(report.title.isEmpty)
    }
}
