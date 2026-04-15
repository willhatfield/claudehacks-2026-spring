import SwiftUI

@main
struct MogMapApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var profileViewModel = ProfileViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(locationManager)
                .environmentObject(profileViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
