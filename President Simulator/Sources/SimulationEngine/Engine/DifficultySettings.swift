import Foundation

/// Difficulty modifiers applied to stat changes and event selection.
public struct DifficultySettings {
    public let name: String
    /// Multiplier applied to negative stat impacts on the player.
    let negativeImpactMultiplier: Double
    /// Multiplier applied to positive stat impacts.
    let positiveImpactMultiplier: Double
    /// Approval decay per turn (higher = harder to maintain).
    let approvalDecayPerTurn: Double
    /// Congress starts more hostile.
    let congressPenalty: Double
    /// Crisis frequency multiplier.
    let crisisFrequency: Double

    public static let difficulties: [String: DifficultySettings] = [
        "Easy": DifficultySettings(name: "Easy", negativeImpactMultiplier: 0.7, positiveImpactMultiplier: 1.2,
                                   approvalDecayPerTurn: 0.5, congressPenalty: 0, crisisFrequency: 0.7),
        "Normal": DifficultySettings(name: "Normal", negativeImpactMultiplier: 1.0, positiveImpactMultiplier: 1.0,
                                     approvalDecayPerTurn: 1.0, congressPenalty: 0, crisisFrequency: 1.0),
        "Hard": DifficultySettings(name: "Hard", negativeImpactMultiplier: 1.3, positiveImpactMultiplier: 0.85,
                                   approvalDecayPerTurn: 1.6, congressPenalty: -10, crisisFrequency: 1.5),
    ]

    public static func `for`(_ name: String) -> DifficultySettings {
        difficulties[name] ?? difficulties["Normal"]!
    }
}
