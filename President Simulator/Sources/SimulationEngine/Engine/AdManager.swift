import Foundation

/// Ad placement points in the game flow.
public enum AdPlacement: String, CaseIterable, Codable {
    case betweenTurns      // interstitial after outcome, before next event
    case premiumChoice     // rewarded ad to unlock a premium/powerful choice
    case secondChance      // rewarded ad to undo/soften a negative consequence
    case reviveAfterLoss   // rewarded ad to continue after election loss
    case hint              // rewarded ad to reveal likely trade-offs
}

/// Protocol for showing ads. Engine stays SDK-free; concrete implementation lives
/// in the app target (e.g. Google Mobile Ads, AppLovin, Unity Ads).
public protocol AdManagerProtocol: AnyObject {
    func showRewardedAd(for placement: AdPlacement, onComplete: @escaping (Bool) -> Void)
    func showInterstitial(for placement: AdPlacement, onComplete: @escaping () -> Void)
    var adsRemoved: Bool { get }
    func grantPremiumChoice(token: String)
    func hasPremiumChoice(token: String) -> Bool
}

/// No-op ad manager for development, previews, and tests.
public final class AdManagerStub: AdManagerProtocol {
    public var adsRemoved: Bool = false
    private var grantedTokens: Set<String> = []

    public init() {}

    public func showRewardedAd(for placement: AdPlacement, onComplete: @escaping (Bool) -> Void) {
        // Simulate user completing the ad in debug; grant reward.
        onComplete(true)
    }

    public func showInterstitial(for placement: AdPlacement, onComplete: @escaping () -> Void) {
        onComplete()
    }

    public func grantPremiumChoice(token: String) {
        grantedTokens.insert(token)
    }

    public func hasPremiumChoice(token: String) -> Bool {
        grantedTokens.contains(token)
    }
}
