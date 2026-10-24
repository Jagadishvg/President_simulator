import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingHistory = false

    let onCabinet: () -> Void
    let onCongress: () -> Void
    let onInternational: () -> Void
    let onElections: () -> Void
    let onAchievements: () -> Void
    let onSettings: () -> Void
    let onHistory: () -> Void

    var body: some View {
        AnyView(
            Group {
                if let state = viewModel.state {
                    dashboardContent(state: state)
                } else {
                    EmptyView()
                }
            }
        )
    }

    @ViewBuilder
    private func dashboardContent(state: GameState) -> some View {
        NavigationStack {
            ZStack {
                Color.govBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("The White House")
                                    .font(.govSubheading)
                                    .foregroundColor(.govAccent)
                                Text("\(state.presidentName)  ·  \(state.presidentParty)")
                                    .font(.govHeading)
                                    .foregroundColor(.govText)
                                Text("Year \(state.year) of 4  ·  Turn \(state.turn) / \(state.termMaxTurns)")
                                    .font(.govCaption)
                                    .foregroundColor(.govTextSecondary)
                            }
                            Spacer()
                            Button(action: { try? viewModel.saveGame() }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.govTextSecondary)
                            }
                            .buttonStyle(.plain)
                            Menu {
                                Button("History", action: onHistory)
                                Button("Cabinet", action: onCabinet)
                                Button("Congress", action: onCongress)
                                Button("International", action: onInternational)
                                Button("Elections", action: onElections)
                                Button("Achievements", action: onAchievements)
                                Button("Settings", action: onSettings)
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.govTextSecondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // Stat cards grid
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                            ForEach(state.stats.allStats, id: \.key) { stat in
                                StatCard(stat: stat)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Approval + voter groups
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Public Approval (Weighted)")
                                    .font(.govCaption)
                                    .foregroundColor(.govTextSecondary)
                                Spacer()
                                Text(String(format: "%.0f%%", viewModel.weightedApproval()))
                                    .font(.govBody)
                                    .foregroundColor(.govText)
                                    .bold()
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.govBorder)
                                        .frame(height: 6)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(approvalColor)
                                        .frame(width: CGFloat(viewModel.weightedApproval()/100) * geo.size.width, height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal, 20)

                        // Quick actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Next Action")
                                .font(.govCaption)
                                .foregroundColor(.govTextSecondary)
                            HStack(spacing: 10) {
                                Button(action: { viewModel.continueToNextTurn() }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                            .foregroundColor(.govAccent)
                                        Text("Next Challenge")
                                            .font(.govBody)
                                            .foregroundColor(.govText)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.govTextSecondary)
                                    }
                                    .padding(14)
                                    .background(Color.govPanel)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.govBorder, lineWidth: 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)

                                Button(action: onHistory) {
                                    HStack {
                                        Image(systemName: "book.fill")
                                            .foregroundColor(.govAccent)
                                        Text("History")
                                            .font(.govBody)
                                            .foregroundColor(.govText)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.govTextSecondary)
                                    }
                                    .padding(14)
                                    .background(Color.govPanel)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.govBorder, lineWidth: 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 20)
                    }
                }

                // Floating next-event button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.continueToNextTurn()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Next Challenge")
                                    .font(.govButton)
                            }
                            .foregroundColor(.govBackground)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 16)
                            .background(Color.govAccent)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                        .padding(24)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("End Presidency") { /* handled */ }
                        .foregroundColor(.govTextMuted)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { try? viewModel.saveGame() }
                        .foregroundColor(.govTextSecondary)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(viewModel: viewModel)
            }
        }
    }

    private var approvalColor: Color {
        let v = viewModel.weightedApproval()
        return v > 60 ? Color.statGood : (v > 40 ? Color.statWarn : Color.statBad)
    }
}

struct StatCard: View {
    let stat: NationalStat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stat.key.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
                    .capitalized)
                    .font(.govCaption)
                    .foregroundColor(.govTextSecondary)
                Spacer()
                Image(systemName: trendIcon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(trendColor)
            }
            Text(String(format: "%.0f", stat.clampedValue))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.govText)
            Text(String(format: "%+.1f", stat.delta))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(trendColor)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.govBorder)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: CGFloat(clampedFraction) * geo.size.width, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .background(Color.govPanel)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.govBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var trendIcon: String {
        stat.delta > 0.5 ? "arrow.up" : (stat.delta < -0.5 ? "arrow.down" : "minus")
    }

    private var trendColor: Color {
        stat.delta > 0.5 ? Color.statGood : (stat.delta < -0.5 ? Color.statBad : Color.govTextSecondary)
    }

    private var barColor: Color {
        switch stat.key {
        case "inflation", "unemployment", "nationalDebt":
            return stat.value < 40 ? Color.statGood : (stat.value > 60 ? Color.statBad : Color.statWarn)
        default:
            return stat.value > 60 ? Color.statGood : (stat.value < 40 ? Color.statBad : Color.statWarn)
        }
    }

    private var clampedFraction: Double {
        let v = stat.clampedValue
        return (v - stat.min) / (stat.max - stat.min)
    }
}
