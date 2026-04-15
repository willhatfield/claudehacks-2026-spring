import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @StateObject private var mapViewModel = MapViewModel()

    var body: some View {
        TabView {
            MapScreenView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .environmentObject(mapViewModel)
        .onAppear {
            mapViewModel.configure(profile: profileViewModel, location: locationManager)
            locationManager.requestPermission()
        }
    }
}
