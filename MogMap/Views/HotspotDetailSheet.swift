import SwiftUI

struct HotspotDetailSheet: View {
    let hotspot: Hotspot
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(hotspot.emoji)
                                .font(.system(size: 48))
                            Spacer()
                            distanceBadge
                        }
                        Text(hotspot.name)
                            .font(.title2.bold())
                        Text("\"\(hotspot.vibe)\"")
                            .font(.subheadline)
                            .foregroundStyle(Color(red: 0.486, green: 0.231, blue: 0.929))
                            .italic()
                        Text(hotspot.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                    .padding()
                    .background(Color(red: 0.13, green: 0.13, blue: 0.22))
                    .cornerRadius(16)

                    // Nearby Players
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Nearby Players")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(mapViewModel.nearbyFakePlayers, id: \.name) { player in
                                    VStack(spacing: 4) {
                                        Text(player.emoji)
                                            .font(.system(size: 28))
                                            .frame(width: 50, height: 50)
                                            .background(Color(red: 0.13, green: 0.13, blue: 0.22))
                                            .clipShape(Circle())
                                        Text(player.name)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 70)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Farm Aura Button
                    VStack(spacing: 8) {
                        let isNear = mapViewModel.isUserNearHotspot(hotspot, userLocation: locationManager.userLocation)

                        Button {
                            mapViewModel.farmAura(userLocation: locationManager.userLocation)
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Farm Aura")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isNear ? Color(red: 0.984, green: 0.753, blue: 0.141) : Color.gray.opacity(0.3))
                            .foregroundStyle(isNear ? .black : .secondary)
                            .cornerRadius(12)
                        }
                        .disabled(!isNear)

                        if let result = mapViewModel.farmResult {
                            Text(result.message)
                                .font(.caption)
                                .foregroundStyle(result.isNearHotspot ? Color(red: 0.984, green: 0.753, blue: 0.141) : .red)
                                .multilineTextAlignment(.center)
                        }

                        if !isNear {
                            Text("Get within \(Int(hotspot.radiusMeters))m to farm aura")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    // Generate Quest Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Squad Quest")
                            .font(.headline)
                            .padding(.horizontal)

                        if let quest = mapViewModel.currentQuest {
                            QuestCardView(quest: quest, playerName: "You")
                                .environmentObject(mapViewModel)
                                .padding(.horizontal)
                        } else {
                            // Players waiting indicator
                            waitingPlayersView
                                .padding(.horizontal)

                            let isNear = mapViewModel.isUserNearHotspot(hotspot, userLocation: locationManager.userLocation)

                            Button {
                                mapViewModel.generateQuest()
                            } label: {
                                HStack {
                                    if mapViewModel.isGeneratingQuest {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(0.9)
                                    } else {
                                        Image(systemName: "wand.and.stars")
                                    }
                                    Text(mapViewModel.isGeneratingQuest ? "Generating quest..." : "Generate Quest")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isNear
                                    ? Color(red: 0.486, green: 0.231, blue: 0.929)
                                    : Color.gray.opacity(0.3))
                                .foregroundStyle(isNear ? .white : .secondary)
                                .cornerRadius(12)
                            }
                            .disabled(mapViewModel.isGeneratingQuest || !isNear)
                            .padding(.horizontal)

                            if !isNear {
                                Text("Get within \(Int(hotspot.radiusMeters))m to generate a quest")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            } else {
                                Text("Generate a collaborative puzzle quest for you and your nearby squad")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Hotspot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        mapViewModel.showingDetail = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var waitingPlayersView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { index in
                    Image(systemName: index < hotspot.playersWaiting ? "person.fill" : "person")
                        .font(.system(size: 18))
                        .foregroundStyle(index < hotspot.playersWaiting
                            ? Color(red: 0.486, green: 0.231, blue: 0.929)
                            : Color.gray.opacity(0.35))
                }
                Spacer()
                Text(hotspot.playersWaiting == 0
                    ? "No one waiting yet"
                    : "\(hotspot.playersWaiting) player\(hotspot.playersWaiting == 1 ? "" : "s") waiting for a quest")
                    .font(.caption.bold())
                    .foregroundStyle(hotspot.playersWaiting > 0
                        ? Color(red: 0.486, green: 0.231, blue: 0.929)
                        : .secondary)
            }
            .padding(12)
            .background(Color(red: 0.13, green: 0.13, blue: 0.22))
            .cornerRadius(10)
        }
    }

    private var distanceBadge: some View {
        Group {
            if let loc = locationManager.userLocation {
                let dist = HotspotService.distance(from: hotspot, to: loc)
                Text("\(Int(dist))m")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(dist <= hotspot.radiusMeters
                        ? Color(red: 0.984, green: 0.753, blue: 0.141).opacity(0.2)
                        : Color.gray.opacity(0.2))
                    .foregroundStyle(dist <= hotspot.radiusMeters
                        ? Color(red: 0.984, green: 0.753, blue: 0.141)
                        : .secondary)
                    .cornerRadius(8)
            }
        }
    }
}
