import XCTest

final class CoherenceAppUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  @MainActor
  func testSyntheticPrivacyPermissionAndDiagnosticFlow() {
    let app = XCUIApplication()
    app.launchArguments = [
      "COHERENCE_USE_FAKE_SENSORS=1",
      "COHERENCE_AUTHORIZATION_FIXTURE=needs-request",
    ]
    app.launch()

    XCTAssertTrue(app.navigationBars["Coherence"].waitForExistence(timeout: 10))
    XCTAssertTrue(
      app.staticTexts["coherence.phone.privacy.title"].waitForExistence(timeout: 5)
    )

    let reviewButton = app.buttons["coherence.phone.privacy.continue"]
    XCTAssertTrue(reviewButton.exists)
    reviewButton.tap()

    XCTAssertTrue(
      app.staticTexts["coherence.phone.permissions.title"].waitForExistence(timeout: 5)
    )
    XCTAssertEqual(
      app.staticTexts["coherence.phone.permissions.status"].label,
      "Access request needed"
    )
    XCTAssertFalse(app.alerts.firstMatch.exists)

    let requestButton = app.buttons["coherence.phone.permissions.request"]
    XCTAssertTrue(requestButton.exists)
    requestButton.tap()

    XCTAssertTrue(
      app.staticTexts["coherence.phone.overview.title"].waitForExistence(timeout: 5)
    )
    let sensorMode = app.staticTexts["coherence.phone.sensor-mode"]
    XCTAssertTrue(sensorMode.waitForExistence(timeout: 5))
    XCTAssertEqual(sensorMode.label, "Synthetic sensors active")
    XCTAssertTrue(app.staticTexts["coherence.phone.schema-version"].exists)

    let diagnosticsButton = app.buttons["coherence.phone.diagnostics.open"]
    XCTAssertTrue(diagnosticsButton.exists)
    diagnosticsButton.tap()

    XCTAssertTrue(
      app.staticTexts["coherence.phone.diagnostics.title"].waitForExistence(timeout: 5)
    )
    XCTAssertEqual(
      app.staticTexts["coherence.phone.diagnostics.redaction"].label,
      "Biometric values, Excluded"
    )
    XCTAssertTrue(app.staticTexts["coherence.phone.diagnostics.run-id"].exists)
    XCTAssertFalse(app.alerts.firstMatch.exists)
  }
}
