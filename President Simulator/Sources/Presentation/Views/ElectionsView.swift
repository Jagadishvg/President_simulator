import SwiftUI

struct ElectionsView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        let state = viewModel.state

        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Elections")
                        .font(.govTitle)
                        .foregroundColor(.govText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Upcoming")
                            .font(.govCaption)
                            .foregroundColor(.govTextSecondary)

                        if state?.year == 4 {
                            ElectionCard(label: "Presidential Election", turn: state?.turn ?? 0, note: "Decides re-election.")
                        } else {
                            Text("Next election in Year 4 (presidential). Midterms occur in Year 2.")
                                .font(.govBody)
                                .foregroundColor(.govTextSecondary)
                        }

                        if let reElected = state?.reElectionWon {
                            Text(reElected ? "Re-elected for a second term." : "Lost re-election. Term ending.")
                                .font(.govBody)
                                .foregroundColor(reElected ? Color.statGood : Color.statBad)
                        }

                        Divider().background(Color.govBorder)

                        Text("Campaign Promises")
                            .font(.govCaption)
                            .foregroundColor(.govTextSecondary)
                            .padding(.top, 8)

                        if let promises = state?.campaignPromises, !promises.isEmpty {
                            ForEach(Array(promises.keys.sorted()), id: \.self) { id in
                                let kept = promises[id] ?? false
                                HStack {
                                    Text(id.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.govBody)
                                        .foregroundColor(.govText)
                                    Spacer()
                                    Image(systemName: kept ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(kept ? Color.statGood : Color.govTextSecondary)
                                }
                            }
                        } else {
                            Text("No campaign promises recorded yet.")
                                .font(.govBody)
                                .foregroundColor(.govTextSecondary)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Elections")
        .navigationBarTitleDisplayMode(.inline)
    }
}
