import Foundation
import Combine
import AVFoundation
import AudioToolbox

final class AlarmViewModel: ObservableObject {
    @Published var alarms: [Alarm] = []

    private let storageKey = "alarmbrew_alarms_v1"
    private var audioPlayer: AVAudioPlayer?

    init() {
        loadAlarms()
    }

    // MARK: - CRUD

    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        if alarm.isEnabled { AlarmScheduler.shared.schedule(alarm) }
        saveAlarms()
    }

    func updateAlarm(_ alarm: Alarm) {
        guard let idx = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        AlarmScheduler.shared.cancel(alarm.id)
        alarms[idx] = alarm
        if alarm.isEnabled { AlarmScheduler.shared.schedule(alarm) }
        saveAlarms()
    }

    func deleteAlarms(at offsets: IndexSet) {
        offsets.forEach { AlarmScheduler.shared.cancel(alarms[$0].id) }
        alarms.remove(atOffsets: offsets)
        saveAlarms()
    }

    func toggleAlarm(_ alarm: Alarm) {
        var copy = alarm
        copy.isEnabled.toggle()
        updateAlarm(copy)
    }

    // MARK: - Audio

    func startAlarmSound() {
        if let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "alarm", withExtension: "caf") {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try? AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } else {
            AudioServicesPlaySystemSound(SystemSoundID(1005))
        }
    }

    func stopAlarmSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - Persistence

    private func saveAlarms() {
        guard let data = try? JSONEncoder().encode(alarms) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadAlarms() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Alarm].self, from: data)
        else { return }
        alarms = decoded
    }
}
