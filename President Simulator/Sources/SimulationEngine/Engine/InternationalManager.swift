import Foundation

/// International relations: country relationships, diplomatic events, reputation.
public final class InternationalManager {
    private let validator = StatValidator.shared

    public static let countries: [String: (name: String, region: String)] = [
        "canada": ("Canada", "North America"),
        "mexico": ("Mexico", "North America"),
        "uk": ("United Kingdom", "Europe"),
        "germany": ("Germany", "Europe"),
        "france": ("France", "Europe"),
        "japan": ("Japan", "Asia"),
        "southKorea": ("South Korea", "Asia"),
        "china": ("China", "Asia"),
        "russia": ("Russia", "Eurasia"),
        "brazil": ("Brazil", "South America"),
        "india": ("India", "Asia"),
        "saudiArabia": ("Saudi Arabia", "Middle East"),
        "israel": ("Israel", "Middle East"),
    ]

    public func initializeRelations(into state: inout GameState) {
        for (id, _) in Self.countries {
            if state.internationalRelations[id] == nil {
                state.internationalRelations[id] = 40
            }
        }
    }

    public func applyRelationChange(country: String, delta: Double, into state: inout GameState) {
        let current = state.internationalRelations[country] ?? 40
        state.internationalRelations[country] = validator.clamp(current + delta, min: -100, max: 100)
    }

    public func averageRelation(state: GameState) -> Double {
        guard !state.internationalRelations.isEmpty else { return 50 }
        return state.internationalRelations.values.reduce(0, +) / Double(state.internationalRelations.count)
    }

    public func allies(state: GameState) -> [String] {
        state.internationalRelations.filter { $0.value > 40 }.keys.sorted()
    }

    public func rivals(state: GameState) -> [String] {
        state.internationalRelations.filter { $0.value < -20 }.keys.sorted()
    }

    public func relationDescription(_ value: Double) -> String {
        switch value {
        case 70...: return "Close Ally"
        case 40..<70: return "Friendly"
        case 10..<40: return "Cooperative"
        case -10..<10: return "Neutral"
        case -40..<-10: return "Strained"
        case -70..<-40: return "Hostile"
        default: return "Adversary"
        }
    }

    public func relationColor(_ value: Double) -> Color {
        switch value {
        case 70...: return Color(red: 0.3, green: 0.8, blue: 0.5)
        case 40..<70: return Color(red: 0.5, green: 0.85, blue: 0.6)
        case 10..<40: return Color(red: 0.9, green: 0.8, blue: 0.3)
        case -10..<10: return Color(red: 0.8, green: 0.8, blue: 0.8)
        case -40..<-10: return Color(red: 0.95, green: 0.6, blue: 0.3)
        case -70..<-40: return Color(red: 0.95, green: 0.4, blue: 0.4)
        default: return Color(red: 0.9, green: 0.2, blue: 0.2)
        }
    }
}
