import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        let history = viewModel.state?.history.reversed() ?? []

        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Presidential History")
                        .font(.govTitle)
                        .foregroundColor(.govText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    if history.isEmpty {
                        EmptyHistoryView()
                    } else {
                        ForEach(Array(history.enumerated()), id: \.element.id) { index, record in
                            HistoryRow(record: record, turnNumber: viewModel.state?.history.count ?? 0 - index)
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 30)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(.govTextMuted)
            Text("No decisions recorded yet.")
                .font(.govBody)
                .foregroundColor(.govTextSecondary)
            Text("Your choices will appear here as you lead the country.")
                .font(.govCaption)
                .foregroundColor(.govTextMuted)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct HistoryRow: View {
    let record: DecisionRecord
    let turnNumber: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Turn \(turnNumber)")
                    .font(.govCaption)
                    .fontWeight(.bold)
                    .foregroundColor(.govAccent)
                Spacer()
                Text(record.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.govTextMuted)
            }
            Text(record.eventId.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.govBody)
                .foregroundColor(.govText)
                .bold()
            Text(record.choiceTitle)
                .font(.govBody)
                .foregroundColor(.govTextSecondary)
            if !record.statChanges.isEmpty {
                HStack(spacing: 16) {
                    ForEach(Array(record.statChanges.keys.sorted()), id: \.self) { key in
                        Text("\(key): \(record.statChanges[key] ?? 0, specifier: "%+.1f")")
                            .font(.caption2)
                            .foregroundColor(.govTextMuted)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(Color.govPanel)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.govBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
