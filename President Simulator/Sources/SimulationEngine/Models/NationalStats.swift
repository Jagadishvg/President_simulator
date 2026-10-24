import Foundation

/// A single national statistic with a clamped valid range and a recent-change delta.
/// All stats live on a 0-100 scale except treasuryBudget which is unbounded (can be negative).
public struct NationalStat: Codable, Equatable {
    public let key: String
    public let value: Double
    public let previousValue: Double
    public let min: Double
    public let max: Double

    public var delta: Double { value - previousValue }
    public var isImproving: Bool { delta > 0.5 }
    public var isDeclining: Bool { delta < -0.5 }

    public var clampedValue: Double {
        min(max(value, min), max)
    }

    public init(key: String, value: Double, previousValue: Double, min: Double = 0, max: Double = 100) {
        self.key = key
        self.value = value
        self.previousValue = previousValue
        self.min = min
        self.max = max
    }
}

/// Container for all national statistics with centralized validation.
/// Stat changes are applied through StatValidator to prevent out-of-range or contradictory state.
public struct NationalStats: Codable, Equatable {
    // Core indicators (0-100)
    public var publicApproval: NationalStat
    public var economy: NationalStat
    public var inflation: NationalStat
    public var unemployment: NationalStat
    public var nationalSecurity: NationalStat
    public var internationalReputation: NationalStat
    public var congressSupport: NationalStat
    public var socialStability: NationalStat

    // Fiscal (treasury unbounded; debt 0-100)
    public var nationalDebt: NationalStat
    public var treasuryBudget: NationalStat

    public init(
        publicApproval: Double = 55,
        economy: Double = 55,
        inflation: Double = 30,
        unemployment: Double = 5,
        nationalDebt: Double = 40,
        treasuryBudget: Double = 100,
        nationalSecurity: Double = 70,
        internationalReputation: Double = 65,
        congressSupport: Double = 55,
        socialStability: Double = 60
    ) {
        self.publicApproval = NationalStat(key: "publicApproval", value: publicApproval, previousValue: publicApproval)
        self.economy = NationalStat(key: "economy", value: economy, previousValue: economy)
        self.inflation = NationalStat(key: "inflation", value: inflation, previousValue: inflation)
        self.unemployment = NationalStat(key: "unemployment", value: unemployment, previousValue: unemployment)
        self.nationalDebt = NationalStat(key: "nationalDebt", value: nationalDebt, previousValue: nationalDebt)
        self.treasuryBudget = NationalStat(key: "treasuryBudget", value: treasuryBudget, previousValue: treasuryBudget, min: -500, max: 500)
        self.nationalSecurity = NationalStat(key: "nationalSecurity", value: nationalSecurity, previousValue: nationalSecurity)
        self.internationalReputation = NationalStat(key: "internationalReputation", value: internationalReputation, previousValue: internationalReputation)
        self.congressSupport = NationalStat(key: "congressSupport", value: congressSupport, previousValue: congressSupport)
        self.socialStability = NationalStat(key: "socialStability", value: socialStability, previousValue: socialStability)
    }

    public subscript(key: String) -> NationalStat? {
        switch key {
        case "publicApproval": return publicApproval
        case "economy": return economy
        case "inflation": return inflation
        case "unemployment": return unemployment
        case "nationalDebt": return nationalDebt
        case "treasuryBudget": return treasuryBudget
        case "nationalSecurity": return nationalSecurity
        case "internationalReputation": return internationalReputation
        case "congressSupport": return congressSupport
        case "socialStability": return socialStability
        default: return nil
        }
    }

    public mutating func set(_ key: String, value: Double) {
        guard var stat = self[key] else { return }
        stat = NationalStat(key: key, value: value, previousValue: stat.value, min: stat.min, max: stat.max)
        switch key {
        case "publicApproval": publicApproval = stat
        case "economy": economy = stat
        case "inflation": inflation = stat
        case "unemployment": unemployment = stat
        case "nationalDebt": nationalDebt = stat
        case "treasuryBudget": treasuryBudget = stat
        case "nationalSecurity": nationalSecurity = stat
        case "internationalReputation": internationalReputation = stat
        case "congressSupport": congressSupport = stat
        case "socialStability": socialStability = stat
        default: break
        }
    }

    /// Applies a delta to a stat, clamping to its valid range.
    public mutating func adjust(_ key: String, by delta: Double) {
        guard var stat = self[key] else { return }
        let newValue = stat.value + delta
        stat = NationalStat(key: key, value: newValue, previousValue: stat.value, min: stat.min, max: stat.max)
        switch key {
        case "publicApproval": publicApproval = stat
        case "economy": economy = stat
        case "inflation": inflation = stat
        case "unemployment": unemployment = stat
        case "nationalDebt": nationalDebt = stat
        case "treasuryBudget": treasuryBudget = stat
        case "nationalSecurity": nationalSecurity = stat
        case "internationalReputation": internationalReputation = stat
        case "congressSupport": congressSupport = stat
        case "socialStability": socialStability = stat
        default: break
        }
    }

    /// All stats as a flat array, useful for UI and charting.
    public var allStats: [NationalStat] {
        [publicApproval, economy, inflation, unemployment, nationalDebt, treasuryBudget,
         nationalSecurity, internationalReputation, congressSupport, socialStability]
    }
}
