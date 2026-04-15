import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: PlayerProfile

    private let defaultsKey = "mogmap_player_profile"

    init() {
        if let data = UserDefaults.standard.data(forKey: "mogmap_player_profile"),
           let saved = try? JSONDecoder().decode(PlayerProfile.self, from: data) {
            profile = saved
        } else {
            profile = PlayerProfile(
                playerName: ProfileViewModel.generatePlayerName(),
                totalAura: 0,
                currentStreak: 0,
                longestStreak: 0,
                lastQuestDate: nil,
                questsCompleted: 0,
                completedQuestIds: [],
                farmedHotspotIds: [],
                lastFarmResetDate: nil
            )
            save()
        }
        checkDailyReset()
    }

    private static func generatePlayerName() -> String {
        let adjectives = ["Sigma", "Delulu", "Rizzy", "Bussin", "Based", "Glazed", "Pressed", "Cooked"]
        let nouns = ["Squirrel", "Mogger", "Legend", "Dynamo", "Menace", "Goblin", "Wizard", "Demon"]
        let number = Int.random(in: 1...99)
        return "\(adjectives.randomElement()!)\(nouns.randomElement()!)\(number)"
    }

    func addAura(_ amount: Int) {
        profile.addAura(amount)
        save()
    }

    func completeQuest(questId: String, aura: Int) {
        profile.addAura(aura)
        profile.recordQuest(id: questId)
        save()
    }

    func recordFarm(hotspotId: String) {
        profile.recordFarm(hotspotId: hotspotId)
        save()
    }

    func resetDailyFarms() {
        profile.resetDailyFarms()
        save()
    }

    private func checkDailyReset() {
        guard let lastReset = profile.lastFarmResetDate else {
            profile.lastFarmResetDate = Date()
            save()
            return
        }
        if !Calendar.current.isDateInToday(lastReset) {
            resetDailyFarms()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
