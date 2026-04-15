import Foundation
import CoreLocation
import MapKit
import SwiftUI

@MainActor
class MapViewModel: ObservableObject {
    @Published var selectedHotspot: Hotspot?
    @Published var showingDetail: Bool = false
    @Published var isGeneratingQuest: Bool = false
    @Published var currentQuest: GeneratedQuest?
    @Published var questError: String?
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.0731, longitude: -89.4012),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    ))
    @Published var farmResult: FarmResult?
    @Published var nearbyFakePlayers: [(name: String, emoji: String)] = []
    @Published var questTimeRemaining: TimeInterval?
    @Published var questExpired: Bool = false

    private var profileViewModel: ProfileViewModel?
    private var locationManager: LocationManager?
    private var questTimer: Timer?

    func configure(profile: ProfileViewModel, location: LocationManager) {
        self.profileViewModel = profile
        self.locationManager = location
    }

    func selectHotspot(_ hotspot: Hotspot) {
        selectedHotspot = hotspot
        currentQuest = nil
        questError = nil
        farmResult = nil
        questExpired = false
        stopQuestTimer()
        nearbyFakePlayers = FakePlayers.random(Int.random(in: 2...3))
        showingDetail = true
    }

    func generateQuest() {
        guard let hotspot = selectedHotspot,
              let profile = profileViewModel else { return }

        isGeneratingQuest = true
        questError = nil
        currentQuest = nil

        let playerName = profile.profile.playerName
        let fakePlayers = nearbyFakePlayers
        let allPlayerNames = [playerName] + fakePlayers.map { $0.name }

        Task {
            do {
                let quest = try await ClaudeAPIClient.generateQuest(
                    hotspot: hotspot,
                    playerName: playerName,
                    playerCount: allPlayerNames.count
                )
                isGeneratingQuest = false
                currentQuest = quest
                startQuestTimer(for: quest)
            } catch {
                let fallback = ClaudeAPIClient.fallbackQuest(for: hotspot, playerNames: allPlayerNames)
                isGeneratingQuest = false
                currentQuest = fallback
                startQuestTimer(for: fallback)
            }
        }
    }

    func farmAura(userLocation: CLLocation?) {
        guard let hotspot = selectedHotspot,
              let profile = profileViewModel,
              let userLocation = userLocation else {
            farmResult = FarmResult(aura: 0, message: "Location not available", isNearHotspot: false)
            return
        }

        guard HotspotService.isWithinRadius(of: hotspot, userLocation: userLocation) else {
            let distance = Int(HotspotService.distance(from: hotspot, to: userLocation))
            farmResult = FarmResult(
                aura: 0,
                message: "You need to be at \(hotspot.name) to farm aura. You're \(distance)m away.",
                isNearHotspot: false
            )
            return
        }

        let alreadyFarmed = profile.profile.farmedHotspotIds.contains(hotspot.id)
        let aura = AuraScoringService.auraForFarming(hotspot: hotspot, alreadyFarmed: alreadyFarmed)

        profile.recordFarm(hotspotId: hotspot.id)
        profile.addAura(aura)

        let message = alreadyFarmed
            ? "Already farmed today (+\(aura) aura)"
            : "Aura farmed! +\(aura) aura"
        farmResult = FarmResult(aura: aura, message: message, isNearHotspot: true)

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func completeQuest() {
        guard let quest = currentQuest,
              let profile = profileViewModel else { return }

        stopQuestTimer()
        profile.completeQuest(questId: quest.id, aura: quest.auraReward)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        currentQuest = nil
        questExpired = false
        showingDetail = false
    }

    // MARK: - Timer

    private func timerDuration(for difficulty: String) -> TimeInterval {
        switch difficulty.lowercased() {
        case "easy":   return 15 * 60
        case "hard":   return 45 * 60
        default:       return 30 * 60  // medium
        }
    }

    private func startQuestTimer(for quest: GeneratedQuest) {
        stopQuestTimer()
        questExpired = false
        questTimeRemaining = timerDuration(for: quest.difficulty)

        questTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                guard let remaining = self.questTimeRemaining else { return }
                if remaining <= 1 {
                    self.questTimeRemaining = 0
                    self.questExpired = true
                    self.stopQuestTimer()
                } else {
                    self.questTimeRemaining = remaining - 1
                }
            }
        }
    }

    private func stopQuestTimer() {
        questTimer?.invalidate()
        questTimer = nil
        questTimeRemaining = nil
    }

    func centerOnUser(userLocation: CLLocation?) {
        guard let location = userLocation else { return }
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }

    func isUserNearHotspot(_ hotspot: Hotspot, userLocation: CLLocation?) -> Bool {
        guard let loc = userLocation else { return false }
        return HotspotService.isWithinRadius(of: hotspot, userLocation: loc)
    }

    func distanceToHotspot(_ hotspot: Hotspot, userLocation: CLLocation?) -> String {
        guard let loc = userLocation else { return "Unknown distance" }
        let meters = HotspotService.distance(from: hotspot, to: loc)
        if meters < 1000 {
            return "\(Int(meters))m away"
        } else {
            return String(format: "%.1fkm away", meters / 1000)
        }
    }
}

struct FarmResult {
    let aura: Int
    let message: String
    let isNearHotspot: Bool
}
