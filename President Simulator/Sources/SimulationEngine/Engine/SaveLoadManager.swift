import Foundation

/// Persists GameState to disk as versioned JSON.
/// Handles migrations between save versions so older saves stay loadable.
public final class SaveLoadManager {
    public static let shared = SaveLoadManager()
    private init() {}

    public let saveFileName = "presidentsim_save.json"
    public let currentVersion: Int = GameState.saveVersion

    private var saveURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(saveFileName)
    }

    public func save(_ state: GameState) throws {
        guard let url = saveURL else {
            throw SaveError.noDocumentsDirectory
        }
        var stateToSave = state
        stateToSave.saveVersion = currentVersion
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(stateToSave)
        try data.write(to: url, options: .atomic)
    }

    public func load() throws -> GameState {
        guard let url = saveURL else {
            throw SaveError.noDocumentsDirectory
        }
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw SaveError.noSaveFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var state = try decoder.decode(GameState.self, from: data)
        state = migrate(state: state)
        return state
    }

    public func saveExists() -> Bool {
        guard let url = saveURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    public func deleteSave() throws {
        guard let url = saveURL else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private func migrate(state: GameState) -> GameState {
        var migrated = state
        switch migrated.saveVersion {
        case 1:
            break // current
        default:
            // Future migrations: add new fields with defaults here.
            break
        }
        migrated.saveVersion = currentVersion
        return migrated
    }
}

public enum SaveError: Error, LocalizedError {
    case noDocumentsDirectory
    case noSaveFound
    case decodeFailed(String)

    public var errorDescription: String? {
        switch self {
        case .noDocumentsDirectory: return "Unable to access the documents directory."
        case .noSaveFound: return "No saved game found."
        case .decodeFailed(let msg): return "Failed to decode save data: \(msg)"
        }
    }
}
