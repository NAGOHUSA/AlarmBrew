import SwiftUI

struct ContentView: View {
    @EnvironmentObject var alarmViewModel: AlarmViewModel
    @State private var activeAlarmUserInfo: [AnyHashable: Any]?
    @State private var showActiveAlarm = false

    var body: some View {
        AlarmListView()
            .onReceive(NotificationCenter.default.publisher(for: .alarmDidFire)) { note in
                activeAlarmUserInfo = note.userInfo
                showActiveAlarm = true
            }
            .fullScreenCover(isPresented: $showActiveAlarm) {
                ActiveAlarmView(alarmUserInfo: activeAlarmUserInfo) {
                    showActiveAlarm = false
                }
                .environmentObject(alarmViewModel)
            }
    }
}
