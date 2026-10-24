import SwiftUI

struct SetupView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = "President"
    @State private var selectedParty = "Democratic"
    @State private var selectedStyle = "Pragmatic"
    @State private var selectedDifficulty = "Normal"
    @State private var selectedScenario = "default"

    let parties = ["Democratic", "Republican", "Independent"]
    let styles = ["Pragmatic", "Idealistic", "Hardline", "Conciliatory"]
    let difficulties = ["Easy", "Normal", "Hard"]
    let scenarios: [(id: String, name: String, desc: String)] = [
        ("default", "Standard Term", "A balanced start with average conditions."),
        ("recession", "Recession", "Start with a weak economy and high unemployment."),
        ("boomingEconomy", "Booming Economy", "Start with strong growth and high approval."),
        ("internationalCrisis", "International Crisis", "Start with strained alliances and security threats."),
        ("scandal", "Inherited Scandal", "Start with an administration ethics cloud."),
        ("dividedCongress", "Divided Congress", "Start with minimal legislative support."),
        ("climateEmergency", "Climate Emergency", "Start with an active climate crisis.")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.govBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        Text("New Presidency")
                            .font(.govTitle)
                            .foregroundColor(.govText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("President Name")
                                .font(.govCaption)
                                .foregroundColor(.govTextSecondary)
                            TextField("e.g. Alex Mercer", text: $name)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.govPanel)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.govBorder, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .autocorrectionDisabled()
                        }

                        PickerRow(title: "Political Party", selection: $selectedParty, options: parties)
                        PickerRow(title: "Leadership Style", selection: $selectedStyle, options: styles)
                        PickerRow(title: "Difficulty", selection: $selectedDifficulty, options: difficulties)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Starting Scenario")
                                .font(.govCaption)
                                .foregroundColor(.govTextSecondary)
                            ForEach(scenarios, id: \.id) { scenario in
                                ScenarioButton(scenario: scenario, isSelected: selectedScenario == scenario.id) {
                                    selectedScenario = scenario.id
                                }
                            }
                        }

                        Spacer(minLength: 30)

                        Button(action: {
                            viewModel.startNewPresidency(name: name.isEmpty ? "President" : name,
                                                         party: selectedParty, style: selectedStyle,
                                                         difficulty: selectedDifficulty,
                                                         scenario: selectedScenario)
                        }) {
                            Text("Inaugurate Presidency")
                                .font(.govButton)
                                .foregroundColor(.govBackground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.govAccent)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)

                        Spacer(minLength: 20)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.govTextSecondary)
                }
            }
        }
    }
}

private struct PickerRow: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.govCaption)
                .foregroundColor(.govTextSecondary)
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)
        }
    }
}

private struct ScenarioButton: View {
    let scenario: (id: String, name: String, desc: String)
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.govAccent : Color.govPanel)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.govBackground)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(scenario.name)
                        .font(.govBody)
                        .foregroundColor(.govText)
                    Text(scenario.desc)
                        .font(.govCaption)
                        .foregroundColor(.govTextSecondary)
                }
                Spacer()
            }
            .padding(14)
            .background(isSelected ? Color.govPanelElevated : Color.govPanel)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.govAccent : Color.govBorder, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
