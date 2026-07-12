import XCTest

final class CoherenceAppUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  @MainActor
  func testSyntheticShellLaunches() {
    let app = XCUIApplication()
    app.launchArguments = ["COHERENCE_USE_FAKE_SENSORS=1"]
    app.launch()

    XCTAssertTrue(app.navigationBars["Coherence"].waitForExistence(timeout: 10))
    let sensorMode = app.staticTexts["coherence.phone.sensor-mode"]
    XCTAssertTrue(sensorMode.waitForExistence(timeout: 5))
    XCTAssertEqual(
      sensorMode.label,
      "Synthetic sensors active"
    )
    XCTAssertTrue(app.staticTexts["coherence.phone.schema-version"].exists)
    XCTAssertFalse(app.alerts.firstMatch.exists)
  }
}
