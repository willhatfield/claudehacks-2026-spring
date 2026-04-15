import Foundation

enum FakePlayers {
    static let roster: [(name: String, emoji: String)] = [
        ("AuraMogger99", "⚡️"),
        ("BascomHillSigma", "📚"),
        ("TouchGrassKing", "🌿"),
        ("DeluluDynamo", "✨"),
        ("CrashOutCarl", "💥"),
        ("RizzLord420", "😏"),
        ("NPCEnergy", "🤖"),
        ("MainCharVibes", "🌟"),
        ("LakesideLegend", "🌊"),
        ("GrindsetGuru", "💪"),
        ("VibeCheckVince", "🎯"),
        ("SigmaSquirrelBot", "🐿️")
    ]

    static func random(_ count: Int) -> [(name: String, emoji: String)] {
        Array(roster.shuffled().prefix(count))
    }
}
