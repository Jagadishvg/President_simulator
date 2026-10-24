import SwiftUI

struct InaugurationView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var progress: Double = 0
    @State private var showingContent = false

    var body: some View {
        ZStack {
            Color.govBackground.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "building.columns.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.govAccent)
                    .opacity(showingContent ? 1 : 0)
                    .animation(.easeIn(duration: 0.8), value: showingContent)

                Text("Inauguration Day")
                    .font(.govTitle)
                    .foregroundColor(.govText)
                    .opacity(showingContent ? 1 : 0)
                    .animation(.easeIn(duration: 0.8).delay(0.2), value: showingContent)

                Text(viewModel.state?.presidentName ?? "President")
                    .font(.govHeading)
                    .foregroundColor(.govAccent)
                    .opacity(showingContent ? 1 : 0)
                    .animation(.easeIn(duration: 0.8).delay(0.4), value: showingContent)

                Text(viewModel.state?.presidentParty ?? "")
                    .font(.govCaption)
                    .foregroundColor(.govTextSecondary)
                    .opacity(showingContent ? 1 : 0)
                    .animation(.easeIn(duration: 0.8).delay(0.6), value: showingContent)

                Spacer()

                VStack(spacing: 12) {
                    Text("Swearing in the \(viewModel.state?.year ?? 1)st President of the United States.")
                        .font(.govBody)
                        .foregroundColor(.govTextSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(showingContent ? 1 : 0)
                        .animation(.easeIn(duration: 0.8).delay(0.8), value: showingContent)

                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(.govAccent)
                        .frame(width: 220)
                        .opacity(showingContent ? 1 : 0)
                        .animation(.easeIn(duration: 0.8).delay(1.0), value: showingContent)
                }

                Spacer(minLength: 60)
            }
            .padding()
            .onAppear {
                showingContent = true
                // Simulate oath-taking progress
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
                    progress += 0.02
                    if progress >= 1 {
                        t.invalidate()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            viewModel.showingInauguration = false
                            viewModel.continueToNextTurn()
                        }
                    }
                }
            }
        }
    }
}
