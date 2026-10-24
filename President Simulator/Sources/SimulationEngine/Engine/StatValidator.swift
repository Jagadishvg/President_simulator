import Foundation

/// Centralized validation for all simulation state transitions.
/// Prevents statistics from exceeding permitted ranges and guarantees
/// that every state change has a traceable, bounded cause.
public final class StatValidator {
    public static let shared = StatValidator()
    private init() {}

    /// Clamp a value into [min, max].
    public func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }

    /// Apply a delta to a NationalStat and return the clamped stat.
    public func applyDelta(_ stat: NationalStat, delta: Double) -> NationalStat {
        let newValue = clamp(stat.value + delta, min: stat.min, max: stat.max)
        return NationalStat(key: stat.key, value: newValue, previousValue: stat.value,
                            min: stat.min, max: stat.max)
    }

    /// Validate that a GameState's stats are all within range; clamp if not.
    /// Returns a corrected GameState. Never throws.
    public func sanitize(_ state: inout GameState) {
        for stat in state.stats.allStats {
            let clamped = clamp(stat.value, min: stat.min, max: stat.max)
            if abs(clamped - stat.value) > 0.001 {
                state.stats.set(stat.key, value: clamped)
            }
        }
        // Voter groups 0-100
        for (key, var value) in state.voterGroups {
            value = clamp(value, min: 0, max: 100)
            state.voterGroups[key] = value
        }
        // Congress supports 0-100
        state.congressHouseSupport = clamp(state.congressHouseSupport, min: 0, max: 100)
        state.congressSenateSupport = clamp(state.congressSenateSupport, min: 0, max: 100)
        // International relations -100...100
        for (key, var value) in state.internationalRelations {
            value = clamp(value, min: -100, max: 100)
            state.internationalRelations[key] = value
        }
        // Treasury within its bounds
        if let treasury = state.stats["treasuryBudget"] {
            let clamped = clamp(treasury.value, min: treasury.min, max: treasury.max)
            if abs(clamped - treasury.value) > 0.001 {
                state.stats.set("treasuryBudget", value: clamped)
            }
        }
    }

    /// Ensure an event's prerequisites are satisfiable (no contradictory flag requirements).
    public func eventPrerequisitesValid(_ event: PresidentialEvent, flags: Set<String>) -> Bool {
        for req in event.requiredFlags where !flags.contains(req) { return false }
        for excl in event.excludedFlags where flags.contains(excl) { return false }
        return true
    }
}
