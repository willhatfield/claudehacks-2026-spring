import Foundation

enum AuraScoringService {
    static func auraForFarming(hotspot: Hotspot, alreadyFarmed: Bool) -> Int {
        alreadyFarmed ? 3 : 15
    }

    static func titleForAura(_ aura: Int) -> String {
        switch aura {
        case 0..<100: return "NPC"
        case 100..<500: return "Side Character"
        case 500..<2000: return "Main Character"
        case 2000..<10000: return "Chad"
        default: return "Tung Tung Tung Sahur"
        }
    }

    static func percentileForAura(_ aura: Int) -> String {
        switch aura {
        case 0..<100: return "Bottom 50%"
        case 100..<500: return "Top 40%"
        case 500..<2000: return "Top 15%"
        case 2000..<10000: return "Top 5%"
        default: return "Top 1%"
        }
    }
}
