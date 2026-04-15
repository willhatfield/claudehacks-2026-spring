import SwiftUI
import MapKit

struct MapScreenView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var mapViewModel: MapViewModel

    private let hotspots = HotspotService.allHotspots

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $mapViewModel.cameraPosition) {
                if let userLoc = locationManager.userLocation {
                    Annotation("You", coordinate: userLoc.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.25))
                                .frame(width: 26, height: 26)
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        }
                    }
                }
                ForEach(hotspots) { hotspot in
                    Annotation(hotspot.name, coordinate: hotspot.coordinate) {
                        HotspotMarker(hotspot: hotspot)
                            .onTapGesture {
                                mapViewModel.selectHotspot(hotspot)
                            }
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .ignoresSafeArea()

            // Recenter button
            Button {
                mapViewModel.centerOnUser(userLocation: locationManager.userLocation)
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(Color(red: 0.486, green: 0.231, blue: 0.929))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 32)

            // Location denied overlay
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "location.slash.fill")
                            .foregroundStyle(.red)
                        VStack(alignment: .leading) {
                            Text("Location Required")
                                .font(.headline)
                            Text("Enable location in Settings to farm aura")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundStyle(Color(red: 0.486, green: 0.231, blue: 0.929))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 90)
                }
            }
        }
        .sheet(isPresented: $mapViewModel.showingDetail) {
            if let hotspot = mapViewModel.selectedHotspot {
                HotspotDetailSheet(hotspot: hotspot)
                    .environmentObject(mapViewModel)
                    .environmentObject(locationManager)
            }
        }
    }
}
