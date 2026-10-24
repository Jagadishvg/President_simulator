import Foundation

/// Loads presidential events from a bundled JSON file.
/// Content-driven: new events can be added by editing JSON without touching engine code.
public final class ContentLoader {
    public static let shared = ContentLoader()
    private init() {}

    /// Load all events from a JSON file URL. Throws if the file is missing or malformed.
    public func loadEvents(from url: URL) throws -> [PresidentialEvent] {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let events = try decoder.decode([PresidentialEvent].self, from: data)
        return events
    }

    /// Load events bundled with the app under the given filenames and combine them.
    public func loadBundledEvents(named fileNames: [String] = ["initial_events", "expanded_events"]) throws -> [PresidentialEvent] {
        var all: [PresidentialEvent] = []
        for name in fileNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
                throw ContentError.bundleResourceMissing(name)
            }
            all.append(contentsOf: try loadEvents(from: url))
        }
        return all
    }
}

public enum ContentError: Error, LocalizedError {
    case bundleResourceMissing(String)

    public var errorDescription: String? {
        switch self {
        case .bundleResourceMissing(let name):
            return "Event content resource '\(name).json' not found in bundle."
        }
    }
}
