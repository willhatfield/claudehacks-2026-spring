import Foundation

enum ClaudeAPIClient {
    static func generateQuest(hotspot: Hotspot, playerName: String, playerCount: Int) async throws -> GeneratedQuest {
        let fakePlayers = FakePlayers.random(playerCount - 1)
        let allPlayerNames = [playerName] + fakePlayers.map { $0.name }

        let requestBody: [String: Any] = [
            "hotspotName": hotspot.name,
            "hotspotVibe": hotspot.vibe,
            "hotspotId": hotspot.id,
            "playerNames": allPlayerNames
        ]

        guard let url = URL(string: "http://localhost:3001/api/quest") else {
            throw ClaudeAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ClaudeAPIError.serverError
        }

        let quest = try JSONDecoder().decode(GeneratedQuest.self, from: data)
        return quest
    }

    static func fallbackQuest(for hotspot: Hotspot, playerNames: [String]) -> GeneratedQuest {
        let pieces = playerNames.enumerated().map { index, name in
            let roles = ["Riddle Holder", "Answer Key", "Location Scout", "Challenge Leader"]
            let clues = [
                "You hold the riddle: 'I have hands but cannot clap, I have a face but no eyes. What am I?' Share this with your squad but NOT the answer.",
                "You have the answer key! The answer to the riddle is 'a clock'. Don't reveal it until your team has guessed.",
                "Scout the location! Find the most interesting architectural detail at \(hotspot.name) and describe it to your team.",
                "Lead the challenge! Get your whole squad to strike a sigma pose in front of the main entrance for a group photo."
            ]
            return QuestPiece(
                id: UUID().uuidString,
                playerName: name,
                role: roles[index % roles.count],
                clue: clues[index % clues.count]
            )
        }

        return GeneratedQuest(
            id: UUID().uuidString,
            title: "Squad Sigma Challenge",
            description: "Your crew has been summoned for a classic team quest at \(hotspot.name). Each member holds a piece of the puzzle — coordinate, share your pieces, and complete the challenge together. No cap this quest requires actual teamwork.",
            auraReward: 75,
            difficulty: "medium",
            timeEstimate: "10 min",
            hotspotId: hotspot.id,
            pieces: pieces
        )
    }
}

enum ClaudeAPIError: Error, LocalizedError {
    case invalidURL
    case serverError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid server URL"
        case .serverError: return "Server returned an error"
        case .decodingError: return "Failed to decode quest data"
        }
    }
}
