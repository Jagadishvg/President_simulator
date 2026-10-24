import Foundation

/// Schedules delayed consequences and fires them when their trigger turn arrives.
/// Also manages follow-up event eligibility flags.
public final class ConsequenceScheduler {
    private let validator: StatValidator

    public init(validator: StatValidator = .shared) {
        self.validator = validator
    }

    /// Schedule a delayed effect to fire at a future turn.
    public func schedule(into state: inout GameState, effect: Effect, sourceEventId: String,
                         delay: Int, description: String) {
        guard delay > 0 else { return }
        let triggerTurn = state.turn + delay
        let effect = DelayedEffect(triggerTurn: triggerTurn, effect: effect,
                                   sourceEventId: sourceEventId, description: description)
        state.pendingDelayedEffects.append(effect)
    }

    /// Return all effects whose trigger turn has arrived and not yet fired.
    public func dueEffects(in state: GameState) -> [DelayedEffect] {
        state.pendingDelayedEffects.filter { !$0.hasFired && state.turn >= $0.triggerTurn }
    }

    /// Mark an effect as fired.
    public func markFired(_ effect: inout DelayedEffect) {
        effect.hasFired = true
    }

    /// Remove all fired effects to keep state small.
    public func pruneFired(into state: inout GameState) {
        state.pendingDelayedEffects.removeAll { $0.hasFired }
    }

    /// Register a follow-up event as eligible by adding a flag after a delay.
    public func scheduleFollowUpFlag(into state: inout GameState, flag: String, delay: Int,
                                     sourceEventId: String, description: String) {
        let flagEffect = Effect(historyFlags: [flag])
        schedule(into: &state, effect: flagEffect, sourceEventId: sourceEventId,
                 delay: delay, description: description)
    }
}
