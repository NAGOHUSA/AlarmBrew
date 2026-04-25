import XCTest

final class AlarmBrewUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAlarmListScreenLaunches() {
        XCTAssertTrue(app.navigationBars["AlarmBrew"].exists)
    }

    func testAddAlarmButtonExists() {
        XCTAssertTrue(app.buttons["Add"].exists
                      || app.navigationBars.buttons.element(boundBy: 1).exists)
    }
}
