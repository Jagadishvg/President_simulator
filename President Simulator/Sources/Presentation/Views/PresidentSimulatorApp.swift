import SwiftUI

@main
struct PresidentSimulatorApp: App {
    @StateObject private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if let state = viewModel.state, state.isInaugurated && !viewModel.isGameOver {
                DashboardView(viewModel: viewModel)
            } else if viewModel.isGameOver {
                LegacyView(viewModel: viewModel)
            } else if viewModel.hasSave {
                MainMenuView(viewModel: viewModel)
            } else {
                SetupView(viewModel: viewModel)
            }
        }
    }
}
