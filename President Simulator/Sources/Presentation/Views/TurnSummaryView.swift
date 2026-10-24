import SwiftUI

struct TurnSummaryView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        let result = viewModel.currentTurnResult ?? TurnResult(firedEffects: [], electionResult: nil, resignations: [], nextEvent: nil, isGameOver: false, turn: viewModel.turn, year: viewModel.year)

        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Turn \(result.turn) — Year \(result.year)")
                        .font(.govTitle)
                        .foregroundColor(.govText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    // Fired delayed consequences
                    if !result.firedEffects.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Delayed Consequences")
                                .font(.govCaption)
                                .foregroundColor(.govTextSecondary)
                            ForEach(result.firedEffects) { effect in
                                HStack(spacing: 10) {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.govAccent)
                                    Text(effect.description)
                                        .font(.govBody)
                                        .foregroundColor(.govTextSecondary)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.govPanel)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.govBorder, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Resignations
                    if !result.resignations.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Cabinet Resignations")
                                .font(.govCaption)
                                .foregroundColor(.govTextSecondary)
                            ForEach(result.resignations, id: \.self) { role in
                                HStack {
                                    Image(systemName: "person.badge.minus")
                                        .foregroundColor(.statBad)
                                    Text("\(role) resigned.")
                                        .font(.govBody)
                                        .foregroundColor(.govTextSecondary)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.govPanel)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.govBorder, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Election result
                    if let election = result.electionResult {
                        ElectionCard(election: election)
                            .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 30)

                    Button(action: {
                        viewModel.showingTurnSummary = false
                    }) {
                        Text(result.nextEvent != nil ? "Continue to Next Decision" : "Return to Dashboard")
                            .font(.govButton)
                            .foregroundColor(.govBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.govAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)
                }
            }
        }
        .navigationTitle("Turn Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ElectionCard: View {
    let election: ElectionResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(election.type == "presidential" ? "Presidential Election" : "Midterm Election")
                .font(.govCaption)
                .foregroundColor(.govTextSecondary)
            Text(election.headline)
                .font(.govHeading)
                .foregroundColor(election.tone == "positive" ? Color.statGood : (election.tone == "negative" ? Color.statBad : Color.govTextSecondary))
            Text(election.description)
                .font(.govBody)
                .foregroundColor(.govText)
            HStack(spacing: 20) {
                StatPill(label: "Approval", value: String(format: "%.0f", election.approval))
                StatPill(label: "House", value: String(format: "%.0f", election.houseSupport))
                StatPill(label: "Senate", value: String(format: "%.0f", election.senateSupport))
            }
        }
        .padding(16)
        .background(Color.govPanel)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.govBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.govTextSecondary)
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.govText)
        }
        .padding(8)
        .background(Color.govPanelElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
