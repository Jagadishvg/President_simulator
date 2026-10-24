import Foundation

/// Deterministic pseudo-random number generator.
/// Seeding makes the same state + decision produce reproducible results,
/// which is essential for testable gameplay calculations and debug replay.
public final class SeededRandom {
    private var state: UInt64

    public init(seed: UInt64) {
        // Splitmix64 mixing to avoid weak seeds.
        var z: UInt64 = seed &+ 0x9E3779B97F4A7C15
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        self.state = z
    }

    public convenience init() {
        self.init(seed: UInt64(Date().timeIntervalSince1970 * 1000))
    }

    /// Returns a random double in [0, 1).
    public func nextDouble() -> Double {
        state = state &* 0x2545F4914F6CDD1D &+ 0x7A6D3A3B
        let x = state ^ (state >> 29)
        let y = x ^ (x << 17)
        let z = y ^ (y >> 31)
        return Double(z >> 11) / 9007199254740992.0 // 2^53
    }

    /// Returns a random integer in [lower, upper] inclusive.
    public func nextInt(lower: Int, upper: Int) -> Int {
        guard lower <= upper else { return lower }
        return lower + Int(nextDouble() * Double(upper - lower + 1))
    }

    /// Returns true with the given probability (0.0 ... 1.0).
    public func bool(probability: Double) -> Bool {
        return nextDouble() < probability
    }

    /// Picks a random element from a non-empty array.
    public func element<T>(from array: [T]) -> T {
        precondition(!array.isEmpty)
        return array[Int(nextDouble() * Double(array.count))]
    }
}
