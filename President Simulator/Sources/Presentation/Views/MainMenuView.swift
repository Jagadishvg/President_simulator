import SwiftUI

struct MainMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    let onNewPresidency: () -> Void

    var body: some View {
        ZStack {
            Color.govBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 40)

                Text("PRESIDENT")
                    .font(.govTitle)
                    .foregroundColor(.govText)
                    .tracking(2)
                Text("Simulator")
                    .font(.govTitle)
                    .foregroundColor(.govAccent)
                    .tracking(2)

                Text("A Political Strategy Simulation")
                    .font(.govCaption)
                    .foregroundColor(.govTextSecondary)
                    .tracking(1)
                    .padding(.top, 6)

                Spacer(minLength: 70)

                VStack(spacing: 12) {
                    if viewModel.hasSave {
                        MenuButton(title: "Continue Presidency", icon: "arrow.right.circle.fill") {
                            do { try viewModel.loadGame() } catch {
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }
                    MenuButton(title: "New Presidency", icon: "star.fill", action: onNewPresidency)
                    MenuButton(title: "How to Play", icon: "questionmark.circle") {}
                    MenuButton(title: "Settings", icon: "gearshape") {}
                }

                Spacer(minLength: 40)

                Text("Leader Simulator  ·  MVP Build")
                    .font(.caption2)
                    .foregroundColor(.govTextMuted)
            }
            .padding()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private struct MenuButton: View {
    let title: String
    let icon: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.govAccent)
                    .frame(width: 28)
                Text(title)
                    .font(.govButton)
                    .foregroundColor(.govText)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.govTextSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.govPanel)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.govBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
