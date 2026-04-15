import Foundation
import CoreLocation

struct Hotspot: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let radiusMeters: Double
    let vibe: String
    let emoji: String
    let description: String
    let playersWaiting: Int  // 0–4, how many players are waiting for a quest here

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
