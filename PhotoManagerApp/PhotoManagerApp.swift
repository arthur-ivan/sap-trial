import SwiftUI

@main
struct PhotoManagerApp: App {
    @StateObject private var photoManager = PhotoManagerService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(photoManager)
        }
    }
}
