import SwiftUI

struct EventView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        guard let event = viewModel.currentEvent else {
            return AnyView(EmptyView())
        }

        return AnyView(
            NavigationStack {
                ZStack {
                    Color.govBackground.ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Category + title
                            HStack {
                                Text(event.category.capitalized)
                                    .font(.govCaption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.govAccent)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.govAccent.opacity(0.15))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.govAccent.opacity(0.4), lineWidth: 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Spacer()
                                if event.isEmergency {
                                    Text("EMERGENCY")
                                        .font(.govCaption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.statBad)
                                }
                            }

                            Text(event.title)
                                .font(.govTitle)
                                .foregroundColor(.govText)

                            // Narrative
                            VStack(alignment: .leading, spacing: 10) {
                                Text(event.narrative)
                                    .font(.govBody)
                                    .foregroundColor(.govText)
                                    .lineSpacing(4)
                                if let context = event.context, !context.isEmpty {
                                    Text("Context: \(context)")
                                        .font(.govCaption)
                                        .foregroundColor(.govTextSecondary)
                                        .italic()
                                }
                            }
                            .padding(16)
                            .background(Color.govPanel)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.govBorder, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            // Choices
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Your Decision")
                                    .font(.govCaption)
                                    .foregroundColor(.govTextSecondary)
                                ForEach(event.choices) { choice in
                                    ChoiceButton(
                                        choice: choice,
                                        isLocked: viewModel.isPremiumLocked(choice),
                                        onTap: {
                                            if viewModel.isPremiumLocked(choice) {
                                                viewModel.unlockPremiumChoice(choice) { success in
                                                    if success {
                                                        viewModel.selectChoice(choice)
                                                    }
                                                }
                                            } else {
                                                viewModel.selectChoice(choice)
                                            }
                                        },
                                        onUnlock: {
                                            viewModel.unlockPremiumChoice(choice) { success in
                                                if success {
                                                    viewModel.selectChoice(choice)
                                                }
                                            }
                                        }
                                    )
                                }
                            }

                            Spacer(minLength: 30)
                        }
                        .padding(20)
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Turn \(viewModel.turn) / \(viewModel.state?.termMaxTurns ?? 16)")
                                .font(.govCaption)
                                .foregroundColor(.govTextMuted)
                                .padding(.trailing, 24)
                                .padding(.bottom, 30)
                        }
                    }
                }
                .navigationTitle("Presidential Decision")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Dashboard") { /* navigation handled by parent */ }
                            .foregroundColor(.govTextSecondary)
                    }
                }
                .sheet(isPresented: $viewModel.showingOutcome) {
                    if let outcome = viewModel.currentOutcome {
                        OutcomeView(viewModel: viewModel, outcome: outcome)
                    }
                }
            }
        )
    }
}

struct ChoiceButton: View {
    let choice: Choice
    var isLocked: Bool = false
    var onTap: () -> Void = {}
    var onUnlock: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            if isLocked { onUnlock?() } else { onTap() }
        }) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(choice.id.uppercased())
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(isLocked ? Color.govTextMuted : Color.govAccent)
                            .frame(width: 24, height: 24)
                            .background(isLocked ? Color.govBorder : Color.govAccent.opacity(0.15))
                            .clipShape(Circle())
                        Text(choice.title)
                            .font(.govBody)
                            .foregroundColor(isLocked ? Color.govTextSecondary : Color.govText)
                            .bold()
                        Spacer()
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.govAccent)
                        }
                    }
                    Text(choice.description)
                        .font(.govBody)
                        .foregroundColor(isLocked ? Color.govTextSecondary : Color.govTextSecondary)
                        .lineSpacing(2)
                    HStack {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.govTextMuted)
                        Text(isLocked ? "Watch ad to unlock" : choice.tradeoffHint)
                            .font(.govCaption)
                            .foregroundColor(isLocked ? Color.govAccent : Color.govTextMuted)
                            .bold(isLocked)
                            .italic(!isLocked)
                        Spacer()
                    }
                }
                .padding(16)
                .background(Color.govPanel)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isLocked ? Color.govAccent : Color.govBorder, lineWidth: isLocked ? 2 : 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .opacity(isLocked ? 0.85 : 1.0)
                .disabled(isLocked)
            }
        }
        .buttonStyle(.plain)
    }
}
