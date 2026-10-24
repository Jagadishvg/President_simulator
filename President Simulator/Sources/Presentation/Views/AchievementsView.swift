import SwiftUI

struct AchievementsView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        let achievements = AchievementManager.allAchievements

        ZStack {
            Color.govBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Achievements")
                        .font(.govTitle)
                        .foregroundColor(.govText)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    Text("\(achievements.filter { $0.unlocked }.count) / \(achievements.count)")
                        .font(.govCaption)
                        .foregroundColor(.govTextSecondary)
                        .padding(.horizontal, 20)

                    ForEach(achievements) { achievement in
                        AchievementRow(achievement: achievement)
                            .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: achievement.icon)
                .font(.system(size: 22))
                .foregroundColor(achievement.unlocked ? Color.govAccent : Color.govTextMuted)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.govBody)
                    .foregroundColor(achievement.unlocked ? .govText : .govTextSecondary)
                Text(achievement.description)
                    .font(.govCaption)
                    .foregroundColor(.govTextSecondary)
            }
            Spacer()
            if achievement.unlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.govAccent)
            }
        }
        .padding(14)
        .background(Color.govPanel)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.govBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
