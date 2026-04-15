import Foundation

struct QuestPiece: Codable, Identifiable {
    let id: String
    let playerName: String
    let role: String
    let clue: String
}

struct GeneratedQuest: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let auraReward: Int
    let difficulty: String
    let timeEstimate: String
    let hotspotId: String
    let pieces: [QuestPiece]

    var difficultyColor: String {
        switch difficulty.lowercased() {
        case "easy": return "green"
        case "medium": return "orange"
        case "hard": return "red"
        default: return "gray"
        }
    }
}
