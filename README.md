# President Simulator — iOS Political Strategy Game

## What this is
A four-year presidential simulation for iOS built in Swift + SwiftUI. Pure Swift simulation engine (no UI dependencies, fully XCTest-testable) with a SwiftUI presentation layer.

## Project layout
```
President Simulator/
├── Sources/
│   ├── SimulationEngine/       # Pure Swift game logic (testable)
│   │   ├── Models/             # GameState, stats, events, decisions
│   │   ├── Engine/             # Engine, elections, cabinet, ads, save, validation
│   │   ├── Content/            # Data-driven JSON event library
│   │   └── Random/             # Seeded RNG
│   └── Presentation/           # SwiftUI UI layer
│       ├── Views/              # All screens
│       └── ViewModels/         # GameViewModel bridge
├── Tests/
│   └── SimulationEngineTests/  # XCTest cases
├── codemagic.yaml              # Codemagic CI/CD config
├── .gitignore                  # Xcode / Swift ignores
└── README.md                   # this file
```

## Features (MVP complete)
- Three-choice presidential events (34 events, more addable via JSON)
- 10 national stats with clamping/validation
- Weighted voter-group approval
- Congress (House/Senate) + legislative capital
- Cabinet with attributes, reshuffles, resignations
- Midterm + presidential elections with win/loss endings
- International relations (13 countries)
- Emergency events & time pressure
- Delayed consequences & decision memory
- Fictional news feed per decision
- Presidential history + end-of-term legacy report
- Local JSON save/load with versioning
- Difficulty (Easy/Normal/Hard) + achievements
- Rewarded-ad gate for premium choices + interstitial between turns
- UI: Menu, Setup, Inauguration, Dashboard, Event, Outcome, Turn Summary, Cabinet, Congress, International, Elections, History, Achievements, Settings, Legacy

## How to build
1. Open the `President Simulator` folder in **Xcode on macOS**.
2. Create the Xcode project / add the source files to a target named `PresidentSimulator`.
3. Add `initial_events.json` and `expanded_events.json` to the bundle.
4. Build & run on simulator or device.

## CI/CD (Codemagic)
Push this repo to GitHub, then connect Codemagic using `codemagic.yaml` at the repo root. Codemagic runs on macOS and can build/archive the iOS app and run the XCTest suite.

## Notes
- Swift is **not** available on Windows for compiling iOS apps; editing is fine in VS Code, but building/submitting needs macOS + Xcode.
- Replace `your-email@example.com` in `codemagic.yaml` with your address.
- To add a real ad SDK, implement `AdManagerProtocol` in the app target and swap in for `AdManagerStub`.
