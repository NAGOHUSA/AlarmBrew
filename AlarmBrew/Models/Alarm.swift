import Foundation

struct Alarm: Identifiable, Codable, Equatable {
    var id: UUID
    var label: String
    var time: Date
    var isEnabled: Bool
    /// Weekday integers (1 = Sunday … 7 = Saturday, matching Calendar.weekday)
    var repeatDays: [Int]

    init(
        id: UUID = UUID(),
        label: String = "",
        time: Date = Alarm.defaultWakeTime(),
        isEnabled: Bool = true,
        repeatDays: [Int] = []
    ) {
        self.id = id
        self.label = label
        self.time = time
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
    }

    // MARK: - Helpers

    var formattedTime: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: time)
    }

    var repeatDescription: String {
        if repeatDays.isEmpty { return "Once" }
        let sorted = repeatDays.sorted()
        if sorted == [2, 3, 4, 5, 6] { return "Weekdays" }
        if sorted == [1, 7] { return "Weekends" }
        if sorted == [1, 2, 3, 4, 5, 6, 7] { return "Every Day" }
        let names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return sorted.compactMap { d in
            (1...7).contains(d) ? names[d - 1] : nil
        }.joined(separator: ", ")
    }

    // MARK: - Static helpers

    static func defaultWakeTime() -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 7; c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }
}
