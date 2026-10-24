import SwiftUI

struct CongressView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        let state = viewModel.state

        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Congress")
                        .font(.govTitle)
                        .foregroundColor(.govText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Legislative Support")
                            .font(.govCaption)
                            .foregroundColor(.govTextSecondary)

                        CongressRow(label: "House of Representatives", value: state?.congressHouseSupport ?? 0)
                        CongressRow(label: "Senate", value: state?.congressSenateSupport ?? 0)

                        HStack {
                            Text("Legislative Capital")
                                .font(.govBody)
                                .foregroundColor(.govTextSecondary)
                            Spacer()
                            Text(String(format: "%.0f", state?.legislativeCapital ?? 0))
                                .font(.govBody)
                                .foregroundColor(.govText)
                                .bold()
                        }
                        .padding(.top, 8)

                        Text(state?.congressControlled == true ? "Your party controls Congress." : "Congress is divided or opposition-controlled.")
                            .font(.govCaption)
                            .foregroundColor(.govTextSecondary)
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Congress")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CongressRow: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.govBody)
                    .foregroundColor(.govText)
                Spacer()
                Text(String(format: "%.0f", value))
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
                        .fill(congressColor)
                        .frame(width: CGFloat(value / 100) * geo.size.width, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private var congressColor: Color {
        value > 60 ? Color.statGood : (value > 40 ? Color.statWarn : Color.statBad)
    }
}
