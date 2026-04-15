import Foundation
import CoreLocation

enum HotspotService {
    static let allHotspots: [Hotspot] = [
        Hotspot(id: "memorial-union", name: "Memorial Union Terrace", latitude: 43.0766, longitude: -89.4014, radiusMeters: 75, vibe: "lakeside rizz", emoji: "🏖️", description: "The iconic terrace where vibes are always immaculate. Sunsets, sailboats, and main character energy.", playersWaiting: 4),
        Hotspot(id: "camp-randall", name: "Camp Randall Stadium", latitude: 43.0702, longitude: -89.4121, radiusMeters: 75, vibe: "game day energy", emoji: "🏈", description: "Where legends are made and auras are broken. Jump Around or you're an NPC.", playersWaiting: 2),
        Hotspot(id: "bascom-hill", name: "Bascom Hill", latitude: 43.0754, longitude: -89.4056, radiusMeters: 100, vibe: "academic sigma grind", emoji: "📚", description: "The hill of destiny. Every true sigma has climbed this and questioned their life choices.", playersWaiting: 1),
        Hotspot(id: "state-street-brats", name: "State Street Brats", latitude: 43.0754, longitude: -89.3963, radiusMeters: 100, vibe: "party mode activated", emoji: "🍺", description: "Where the game day chaos peaks. No cap this spot has seen some things.", playersWaiting: 3),
        Hotspot(id: "library-mall", name: "Library Mall", latitude: 43.0748, longitude: -89.4006, radiusMeters: 100, vibe: "main character energy", emoji: "🌟", description: "The crossroads of campus where everyone thinks they're the main character. They might be right.", playersWaiting: 2),
        Hotspot(id: "gordon-dining", name: "Gordon Dining", latitude: 43.0729, longitude: -89.4037, radiusMeters: 125, vibe: "late night chaos", emoji: "🍕", description: "Fuel for the grind. The 2am dining experience that separates the sigmas from the NPCs.", playersWaiting: 1),
        Hotspot(id: "engineering-hall", name: "Engineering Hall", latitude: 43.0717, longitude: -89.4099, radiusMeters: 125, vibe: "nerd mode engaged", emoji: "⚙️", description: "Where future tech bros calculate their aura yield per hour. The sigma grind is real here.", playersWaiting: 0),
        Hotspot(id: "nick-nat", name: "Nick & Nat's Upstairs", latitude: 43.0768, longitude: -89.3956, radiusMeters: 125, vibe: "caffeine arc", emoji: "☕", description: "The coffee spot where every student's origin story begins. Brewed for the chosen ones.", playersWaiting: 2),
        Hotspot(id: "union-south", name: "Union South", latitude: 43.0714, longitude: -89.4073, radiusMeters: 125, vibe: "chill vibes only", emoji: "🎮", description: "Bowling, games, and zero stress. The antidote to Bascom Hill trauma.", playersWaiting: 3),
        Hotspot(id: "sellery-hall", name: "Sellery Hall", latitude: 43.0739, longitude: -89.3968, radiusMeters: 150, vibe: "dorm life NPC", emoji: "🏠", description: "Where freshman arcs begin and dining hall drama unfolds. Classic NPC starter zone.", playersWaiting: 1),
        Hotspot(id: "witte-hall", name: "Witte Hall", latitude: 43.0731, longitude: -89.3979, radiusMeters: 150, vibe: "freshman arc", emoji: "🌱", description: "The origin story location. Every sigma was once a lost freshman here. Growth arc incoming.", playersWaiting: 0),
        Hotspot(id: "dejope-hall", name: "Dejope Hall", latitude: 43.0830, longitude: -89.4042, radiusMeters: 150, vibe: "lakeside dorm energy", emoji: "🌊", description: "Lakeside living with main character energy. The view hits different when you're farming aura.", playersWaiting: 1),
        Hotspot(id: "four-lakes-market", name: "Four Lakes Market", latitude: 43.0734, longitude: -89.3961, radiusMeters: 150, vibe: "dining hall grind", emoji: "🥗", description: "Fueling the aura grind since forever. Swipe in and level up your nutrition stats.", playersWaiting: 3),
        Hotspot(id: "rhetas-market", name: "Rheta's Market", latitude: 43.0755, longitude: -89.4072, radiusMeters: 150, vibe: "snack run", emoji: "🍫", description: "The late night snack pilgrimage spot. Your aura needs fuel too, no cap.", playersWaiting: 2),
        Hotspot(id: "humanities-building", name: "Humanities Building", latitude: 43.0761, longitude: -89.4046, radiusMeters: 150, vibe: "lecture hall sleeper", emoji: "😴", description: "Where existential crises are born and essay deadlines loom. Survive this and you're built different.", playersWaiting: 0)
    ]

    static func nearbyHotspots(to location: CLLocation, within radius: Double) -> [Hotspot] {
        allHotspots.filter { hotspot in
            let hotspotLocation = CLLocation(latitude: hotspot.latitude, longitude: hotspot.longitude)
            return hotspotLocation.distance(from: location) <= radius
        }
    }

    static func isWithinRadius(of hotspot: Hotspot, userLocation: CLLocation) -> Bool {
        let hotspotLocation = CLLocation(latitude: hotspot.latitude, longitude: hotspot.longitude)
        return hotspotLocation.distance(from: userLocation) <= hotspot.radiusMeters
    }

    static func distance(from hotspot: Hotspot, to userLocation: CLLocation) -> Double {
        let hotspotLocation = CLLocation(latitude: hotspot.latitude, longitude: hotspot.longitude)
        return hotspotLocation.distance(from: userLocation)
    }
}
