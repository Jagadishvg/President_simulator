import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingSetup = false
    @State private var showingHistory = false
    @State private var showingCabinet = false
    @State private var showingCongress = false
    @State private var showingInternational = false
    @State private var showingElections = false
    @State private var showingAchievements = false
    @State private var showingSettings = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.showingTurnSummary {
                TurnSummaryView(viewModel: viewModel)
            } else if viewModel.showingInauguration {
                InaugurationView(viewModel: viewModel)
            } else if viewModel.isGameOver {
                LegacyView(viewModel: viewModel)
            } else if viewModel.state == nil {
                MainMenuView(viewModel: viewModel, onNewPresidency: { showingSetup = true })
            } else if viewModel.currentEvent != nil {
                EventView(viewModel: viewModel)
            } else {
                DashboardView(viewModel: viewModel,
                              onCabinet: { showingCabinet = true },
                              onCongress: { showingCongress = true },
                              onInternational: { showingInternational = true },
                              onElections: { showingElections = true },
                              onAchievements: { showingAchievements = true },
                              onSettings: { showingSettings = true },
                              onHistory: { showingHistory = true })
            }
        }
        .sheet(isPresented: $showingSetup) {
            SetupView(viewModel: viewModel)
        }
        .sheet(isPresented: viewModel.showingInauguration) {
            InaugurationView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCabinet) {
            CabinetView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCongress) {
            CongressView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingInternational) {
            InternationalView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingElections) {
            ElectionsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
    }
}
