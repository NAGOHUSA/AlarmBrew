import SwiftUI

@main
struct AlarmBrewApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var alarmViewModel = AlarmViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmViewModel)
        }
    }
}
