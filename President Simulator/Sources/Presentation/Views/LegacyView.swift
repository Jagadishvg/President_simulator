import SwiftUI

struct LegacyView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        let report = viewModel.engine.computeLegacy(state: viewModel.state ?? GameState())

        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Presidential Legacy")
                        .font(.govTitle)
                        .foregroundColor(.govText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(report.title)
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundColor(.govAccent)
                        Text("Score: \(String(format: "%.1f", report.score)) / 100")
                            .font(.govBody)
                            .foregroundColor(.govTextSecondary)
                        Text("\(report.totalDecisions) decisions over 4 years")
                            .font(.govCaption)
                            .foregroundColor(.govTextMuted)
                    }
                    .padding(.horizontal, 20)

                    // Legacy categories
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Evaluation")
                            .font(.govCaption)
                            .foregroundColor(.govTextSecondary)
                            .padding(.horizontal, 20)

                        LegacyCategoryRow(label: "Economic Performance", value: report.economy)
                        LegacyCategoryRow(label: "Public Welfare", value: report.publicWelfare)
                        LegacyCategoryRow(label: "National Security", value: report.nationalSecurity)
                        LegacyCategoryRow(label: "Diplomatic Success", value: report.diplomaticSuccess)
                        LegacyCategoryRow(label: "Government Integrity", value: report.governmentIntegrity)
                        LegacyCategoryRow(label: "Political Stability", value: report.politicalStability)
                        LegacyCategoryRow(label: "Promises Kept", value: report.promisesKept)
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 30)

                    Button(action: {
                        viewModel.state = nil
                        viewModel.currentEvent = nil
                        viewModel.showingLegacy = false
                    }) {
                        Text("Start New Presidency")
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
        .navigationTitle("Legacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LegacyCategoryRow: View {
    let label: String
    let value: Double

    var body: some View {
        HStack {
            Text(label)
                .font(.govBody)
                .foregroundColor(.govText)
            Spacer()
            Text(String(format: "%.0f", value))
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(legacyColor)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(Color.govPanel.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var legacyColor: Color {
        value > 70 ? Color.statGood : (value > 50 ? Color.statWarn : Color.statBad)
    }
}
