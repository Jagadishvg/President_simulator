import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Settings")
                        .font(.govTitle)
                        .foregroundColor(.govText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Game")
                            .font(.govCaption)
                            .foregroundColor(.govTextSecondary)

                        Button(action: { try? viewModel.saveGame() }) {
                            SettingsRow(icon: "doc.on.doc", title: "Save Game")
                        }
                        Button(action: { viewModel.errorMessage = nil }) {
                            SettingsRow(icon: "trash", title: "Delete Save", titleColor: .statBad)
                        }

                        Divider().background(Color.govBorder).padding(.vertical, 8)

                        Text("About")
                            .font(.govCaption)
                            .foregroundColor(.govTextSecondary)
                        SettingsRow(icon: "info.circle", title: "President Simulator — MVP")
                        SettingsRow(icon: "buildings.fill", title: "Version 1.0")
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var titleColor: Color = Color.govText

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.govTextSecondary)
                .frame(width: 30)
            Text(title)
                .font(.govBody)
                .foregroundColor(titleColor)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.govTextMuted)
        }
        .padding(14)
        .background(Color.govPanel)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.govBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
