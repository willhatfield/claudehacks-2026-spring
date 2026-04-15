import SwiftUI

struct QuestCardView: View {
    let quest: GeneratedQuest
    let playerName: String
    @EnvironmentObject var mapViewModel: MapViewModel
    @State private var showingSuccess = false

    private var myPiece: QuestPiece? {
        quest.pieces.first { $0.playerName == playerName }
            ?? quest.pieces.first
    }

    private var otherPieces: [QuestPiece] {
        quest.pieces.filter { $0.playerName != playerName }
    }

    private var difficultyColor: Color {
        switch quest.difficulty.lowercased() {
        case "easy": return .green
        case "medium": return .orange
        case "hard": return .red
        default: return .gray
        }
    }

    private var auraColor: Color {
        Color(red: 0.984, green: 0.753, blue: 0.141)
    }

    private func timerColor(_ remaining: TimeInterval) -> Color {
        let total = remaining / 60
        if total > 10 { return .green }
        if total > 5  { return .orange }
        return .red
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Expired banner
            if mapViewModel.questExpired {
                HStack {
                    Image(systemName: "timer.square")
                    Text("Quest expired! Time ran out, no cap.")
                        .font(.subheadline.bold())
                }
                .foregroundStyle(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.15))
                .cornerRadius(10)
            }

            // Header
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(quest.title)
                        .font(.title3.bold())
                    Spacer()
                    Text(quest.difficulty.uppercased())
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor.opacity(0.2))
                        .foregroundStyle(difficultyColor)
                        .cornerRadius(6)
                }
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(auraColor)
                    Text("+\(quest.auraReward) aura")
                        .font(.subheadline.bold())
                        .foregroundStyle(auraColor)
                    Spacer()
                    // Countdown timer
                    if let remaining = mapViewModel.questTimeRemaining {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundStyle(timerColor(remaining))
                            Text(formattedTime(remaining))
                                .font(.subheadline.monospacedDigit().bold())
                                .foregroundStyle(timerColor(remaining))
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .foregroundStyle(.secondary)
                            Text(quest.timeEstimate)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Text(quest.description)
                .font(.body)
                .foregroundStyle(.secondary)

            Divider()

            // Your Piece
            if let piece = myPiece {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.fill.checkmark")
                            .foregroundStyle(Color(red: 0.486, green: 0.231, blue: 0.929))
                        Text("Your Piece")
                            .font(.headline)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(piece.role)
                            .font(.caption.bold())
                            .foregroundStyle(Color(red: 0.486, green: 0.231, blue: 0.929))
                        Text(piece.clue)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.486, green: 0.231, blue: 0.929).opacity(0.15))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color(red: 0.486, green: 0.231, blue: 0.929).opacity(0.4), lineWidth: 1)
                    )
                }
            }

            // Team Section
            if !otherPieces.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(.secondary)
                        Text("Team")
                            .font(.headline)
                    }
                    VStack(spacing: 6) {
                        ForEach(otherPieces) { piece in
                            HStack {
                                Text(piece.playerName)
                                    .font(.subheadline.bold())
                                Spacer()
                                Text(piece.role)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(6)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(red: 0.13, green: 0.13, blue: 0.22))
                    .cornerRadius(10)
                }
            }

            // Complete Button
            if showingSuccess {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(auraColor)
                    Text("Quest complete! Your squad mogged this challenge.")
                        .font(.subheadline.bold())
                        .foregroundStyle(auraColor)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(auraColor.opacity(0.1))
                .cornerRadius(10)
            } else if !mapViewModel.questExpired {
                Button {
                    withAnimation {
                        showingSuccess = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        mapViewModel.completeQuest()
                    }
                } label: {
                    Text("Mark Complete")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(auraColor)
                        .foregroundStyle(.black)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(red: 0.13, green: 0.13, blue: 0.22))
        .cornerRadius(16)
    }
}
