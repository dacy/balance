import SwiftUI

@main
struct LifeTimerApp: App {
    @StateObject private var familyStore = FamilyStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(familyStore)
        }
    }
}
