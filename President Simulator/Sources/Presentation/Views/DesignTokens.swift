import SwiftUI

extension Color {
    static let govBackground = Color(red: 0.06, green: 0.08, blue: 0.12)     // deep navy
    static let govPanel = Color(red: 0.11, green: 0.15, blue: 0.22)          // slate panel
    static let govPanelElevated = Color(red: 0.14, green: 0.19, blue: 0.28)  // raised panel
    static let govAccent = Color(red: 0.92, green: 0.68, blue: 0.22)         // gold
    static let govAccentDim = Color(red: 0.70, green: 0.50, blue: 0.14)
    static let govText = Color.white
    static let govTextSecondary = Color(red: 0.72, green: 0.80, blue: 0.90)
    static let govTextMuted = Color(red: 0.45, green: 0.52, blue: 0.62)
    static let govBorder = Color(red: 0.20, green: 0.26, blue: 0.36)

    static let statGood = Color(red: 0.30, green: 0.85, blue: 0.60)
    static let statWarn = Color(red: 0.95, green: 0.75, blue: 0.30)
    static let statBad = Color(red: 0.95, green: 0.45, blue: 0.45)
}

extension Font {
    static let govTitle = Font.system(size: 34, weight: .bold, design: .serif)
    static let govHeading = Font.system(size: 22, weight: .semibold, design: .serif)
    static let govSubheading = Font.system(size: 17, weight: .semibold, design: .serif)
    static let govBody = Font.system(size: 16, design: .default)
    static let govCaption = Font.system(size: 13, weight: .medium, design: .default)
    static let govButton = Font.system(size: 17, weight: .semibold, design: .default)
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.govBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.4)
                Text("Inaugurating the Presidency…")
                    .font(.govBody)
                    .foregroundColor(.govTextSecondary)
            }
        }
    }
}
