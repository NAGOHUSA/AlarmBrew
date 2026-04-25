import XCTest
@testable import AlarmBrew

final class AlarmBrewTests: XCTestCase {

    // MARK: - Alarm model

    func testAlarmDefaultTime() {
        let alarm = Alarm()
        let components = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
        XCTAssertEqual(components.hour, 7)
        XCTAssertEqual(components.minute, 0)
    }

    func testAlarmRepeatDescriptionOnce() {
        let alarm = Alarm(repeatDays: [])
        XCTAssertEqual(alarm.repeatDescription, "Once")
    }

    func testAlarmRepeatDescriptionWeekdays() {
        let alarm = Alarm(repeatDays: [2, 3, 4, 5, 6])
        XCTAssertEqual(alarm.repeatDescription, "Weekdays")
    }

    func testAlarmRepeatDescriptionWeekends() {
        let alarm = Alarm(repeatDays: [1, 7])
        XCTAssertEqual(alarm.repeatDescription, "Weekends")
    }

    func testAlarmRepeatDescriptionEveryDay() {
        let alarm = Alarm(repeatDays: [1, 2, 3, 4, 5, 6, 7])
        XCTAssertEqual(alarm.repeatDescription, "Every Day")
    }

    func testAlarmRepeatDescriptionCustom() {
        let alarm = Alarm(repeatDays: [2, 4, 6])
        XCTAssertEqual(alarm.repeatDescription, "Mon, Wed, Fri")
    }

    func testAlarmFormattedTimeNotEmpty() {
        let alarm = Alarm()
        XCTAssertFalse(alarm.formattedTime.isEmpty)
    }

    func testAlarmCodable() throws {
        let original = Alarm(label: "Morning", repeatDays: [2, 3, 4, 5, 6])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Alarm.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testAlarmEquality() {
        let a = Alarm(id: UUID(), label: "Test", repeatDays: [1, 2])
        var b = a
        XCTAssertEqual(a, b)
        b.label = "Changed"
        XCTAssertNotEqual(a, b)
    }
}
