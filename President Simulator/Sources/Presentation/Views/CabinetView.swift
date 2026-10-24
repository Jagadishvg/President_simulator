import SwiftUI

struct CabinetView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        let cabinet = viewModel.state?.cabinet ?? [:]

        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cabinet")
                        .font(.govTitle)
                        .foregroundColor(.govText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ForEach(GameState.cabinetRoles, id: \.self) { role in
                        if let member = cabinet[role] {
                            CabinetRow(member: member, role: role) {
                                viewModel.reshuffleCabinet(role: role)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Cabinet")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CabinetRow: View {
    let member: CabinetMember
    let role: String
    let onReshuffle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(role)
                    .font(.govBody)
                    .foregroundColor(.govText)
                    .bold()
                Spacer()
                Text(member.name)
                    .font(.govBody)
                    .foregroundColor(.govTextSecondary)
            }
            HStack(spacing: 16) {
                AttributePill(label: "Competence", value: member.competence)
                AttributePill(label: "Loyalty", value: member.loyalty)
                AttributePill(label: "Integrity", value: member.integrity)
            }
            HStack(spacing: 16) {
                AttributePill(label: "Alignment", value: member.policyAlignment)
                AttributePill(label: "Ambition", value: member.ambition)
                if member.isResigned {
                    Text("Resigned")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.statBad)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.statBad.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            Button(action: onReshuffle) {
                Text(member.isResigned ? "Replace Minister" : "Reshuffle \(role)")
                    .font(.govCaption)
                    .fontWeight(.semibold)
                    .foregroundColor(.govAccent)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(14)
        .background(Color.govPanel)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.govBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AttributePill: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.govTextSecondary)
            Text(String(format: "%.0f", value))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(attrColor)
        }
        .padding(8)
        .background(Color.govPanelElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var attrColor: Color {
        value > 70 ? Color.statGood : (value > 50 ? Color.statWarn : Color.statBad)
    }
}
