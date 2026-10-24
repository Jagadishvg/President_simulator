import SwiftUI

struct OutcomeView: View {
    @ObservedObject var viewModel: GameViewModel
    let outcome: DecisionOutcome

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Decision Outcome")
                            .font(.govTitle)
                            .foregroundColor(.govText)
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.govTextSecondary)
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(outcome.event.title)
                            .font(.govHeading)
                            .foregroundColor(.govAccent)
                        Text("You chose: \(outcome.choice.title)")
                            .font(.govBody)
                            .foregroundColor(.govText)
                            .bold()
                    }
                    .padding(16)
                    .background(Color.govPanel)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.govBorder, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Outcome narrative
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What Happened")
                            .font(.govCaption)
                            .foregroundColor(.govTextSecondary)
                        Text(outcome.narrative)
                            .font(.govBody)
                            .foregroundColor(.govText)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .background(Color.govPanelElevated)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.govBorder.opacity(0.5), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Stat changes
                    if !outcome.statChanges.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Immediate Effects")
                                .font(.govCaption)
                                .foregroundColor(.govTextSecondary)
                            ForEach(Array(outcome.statChanges.keys.sorted()), id: \.self) { key in
                                StatChangeRow(key: key, delta: outcome.statChanges[key] ?? 0)
                            }
                        }
                        .padding(16)
                        .background(Color.govPanel)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.govBorder, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Pending consequences
                    if !outcome.delayedEffects.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pending Consequences")
                                .font(.govCaption)
                                .foregroundColor(.govTextSecondary)
                            ForEach(outcome.delayedEffects) { effect in
                                HStack(spacing: 10) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.govAccent)
                                    Text(effect.description)
                                        .font(.govBody)
                                        .foregroundColor(.govTextSecondary)
                                    Spacer()
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.govPanel)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.govBorder, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // News
                    if !outcome.newsItems.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("In the News")
                                .font(.govCaption)
                                .foregroundColor(.govTextSecondary)
                            ForEach(outcome.newsItems) { news in
                                NewsRow(news: news)
                            }
                        }
                        .padding(16)
                        .background(Color.govPanel)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.govBorder, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if outcome.hiddenRiskTriggered {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.statBad)
                            Text("A hidden risk has been set in motion. Its consequences may surface later.")
                                .font(.govBody)
                                .foregroundColor(.govTextSecondary)
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.statBad.opacity(0.12))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.statBad.opacity(0.3), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Spacer(minLength: 30)

                    Button(action: {
                        dismiss()
                        viewModel.continueToNextTurn()
                    }) {
                        Text("Continue to Next Turn")
                            .font(.govButton)
                            .foregroundColor(.govBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.govAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 20)
                }
                .padding(20)
            }
        }
    }
}

struct StatChangeRow: View {
    let key: String
    let delta: Double

    var body: some View {
        HStack {
            Text(key.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)
                .capitalized)
                .font(.govBody)
                .foregroundColor(.govTextSecondary)
            Spacer()
            Text(String(format: "%+.1f", delta))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(delta > 0 ? Color.statGood : (delta < 0 ? Color.statBad : Color.govTextSecondary))
        }
    }
}

struct NewsRow: View {
    let news: NewsItem

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(news.toneEmoji)
                .font(.system(size: 16))
            VStack(alignment: .leading, spacing: 2) {
                Text(news.headline)
                    .font(.govBody)
                    .foregroundColor(.govText)
                    .bold()
                Text(news.summary)
                    .font(.govCaption)
                    .foregroundColor(.govTextSecondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        Divider().background(Color.govBorder).padding(.leading, 26)
    }
}

private extension String {
    var toneEmoji: String {
        switch self {
        case "positive": return "✅"
        case "negative": return "⚠️"
        case "mixed": return "🔸"
        default: return "📰"
        }
    }
}
