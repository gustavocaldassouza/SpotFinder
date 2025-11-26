import SwiftUI

@main
struct SpotFinderApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MapScreen()
                    .environmentObject(authViewModel)
            } else {
                SignInView(viewModel: authViewModel)
            }
        }
    }
}
