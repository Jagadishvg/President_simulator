import SwiftUI

struct InternationalView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        let relations = viewModel.state?.internationalRelations ?? [:]

        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("International Relations")
                        .font(.govTitle)
                        .foregroundColor(.govText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    Text(String(format: "Reputation: %.0f", viewModel.state?.stats.internationalReputation.value ?? 0))
                        .font(.govBody)
                        .foregroundColor(.govTextSecondary)
                        .padding(.horizontal, 20)

                    ForEach(InternationalManager.countries.keys.sorted(), id: \.self) { countryId in
                        let info = InternationalManager.countries[countryId]!
                        let value = relations[countryId] ?? 40
                        InternationalRow(country: info.name, value: value)
                            .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("International")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InternationalRow: View {
    let country: String
    let value: Double

    var body: some View {
        HStack(spacing: 12) {
            Text(country)
                .font(.govBody)
                .foregroundColor(.govText)
            Spacer()
            Text(InternationalManager().relationDescription(value))
                .font(.govCaption)
                .fontWeight(.semibold)
                .foregroundColor(InternationalManager().relationColor(value))
            Text(String(format: "%.0f", value))
                .font(.govCaption)
                .foregroundColor(.govTextSecondary)
        }
        .padding(12)
        .background(Color.govPanel)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.govBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
