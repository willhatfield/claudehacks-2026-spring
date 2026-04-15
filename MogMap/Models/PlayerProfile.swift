import Foundation

struct PlayerProfile: Codable {
    var playerName: String
    var totalAura: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastQuestDate: Date?
    var questsCompleted: Int
    var completedQuestIds: Set<String>
    var farmedHotspotIds: Set<String>
    var lastFarmResetDate: Date?

    var currentTitle: String {
        AuraScoringService.titleForAura(totalAura)
    }

    var percentileEstimate: String {
        AuraScoringService.percentileForAura(totalAura)
    }

    var nextTitle: String? {
        switch totalAura {
        case 0..<100: return "Side Character"
        case 100..<500: return "Main Character"
        case 500..<2000: return "Sigma"
        case 2000..<10000: return "Chad"
        case 10000..<15000: return "Tung Tung Tung Sahur"
        default: return nil
        }
    }

    var auraForNextTitle: Int? {
        switch totalAura {
        case 0..<100: return 100
        case 100..<500: return 500
        case 500..<2000: return 2000
        case 2000..<10000: return 10000
        default: return nil
        }
    }

    var progressToNextTitle: Double {
        switch totalAura {
        case 0..<100: return Double(totalAura) / 100.0
        case 100..<500: return Double(totalAura - 100) / 400.0
        case 500..<2000: return Double(totalAura - 500) / 1500.0
        case 2000..<10000: return Double(totalAura - 2000) / 8000.0
        default: return 1.0
        }
    }

    mutating func addAura(_ amount: Int) {
        totalAura += amount
    }

    mutating func recordQuest(id: String) {
        questsCompleted += 1
        completedQuestIds.insert(id)
        let now = Date()
        if let last = lastQuestDate, Calendar.current.isDate(last, inSameDayAs: now) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        lastQuestDate = now
    }

    mutating func recordFarm(hotspotId: String) {
        farmedHotspotIds.insert(hotspotId)
    }

    mutating func resetDailyFarms() {
        farmedHotspotIds = []
        lastFarmResetDate = Date()
    }
}
