import CoherenceAcquisition
import CoherenceCore
import Foundation
import Testing

@testable import CoherenceApp

private actor DelayedRefreshAuthorizationService: MeasurementAuthorizationService {
  private let staleSnapshot: MeasurementAuthorizationSnapshot
  private var currentSnapshotValue: MeasurementAuthorizationSnapshot
  private let requestRecord: MeasurementAuthorizationRequestRecord
  private var hasDelayedRefresh = false
  private var delayedRefreshContinuation:
    CheckedContinuation<MeasurementAuthorizationSnapshot, Never>?

  init(
    staleSnapshot: MeasurementAuthorizationSnapshot,
    completedSnapshot: MeasurementAuthorizationSnapshot,
    requestRecord: MeasurementAuthorizationRequestRecord
  ) {
    self.staleSnapshot = staleSnapshot
    currentSnapshotValue = completedSnapshot
    self.requestRecord = requestRecord
  }

  func currentSnapshot() async -> MeasurementAuthorizationSnapshot {
    guard !hasDelayedRefresh else {
      return currentSnapshotValue
    }

    hasDelayedRefresh = true
    return await withCheckedContinuation { continuation in
      delayedRefreshContinuation = continuation
    }
  }

  func requestAuthorization() -> MeasurementAuthorizationRequestRecord {
    requestRecord
  }

  func waitUntilRefreshIsSuspended() async {
    while delayedRefreshContinuation == nil {
      await Task.yield()
    }
  }

  func releaseStaleRefresh() {
    delayedRefreshContinuation?.resume(returning: staleSnapshot)
    delayedRefreshContinuation = nil
  }
}

struct PhoneCompositionTests {
  @Test
  @MainActor
  func fakeArgumentSelectsSyntheticAdapter() async throws {
    let composition = PhoneCompositionRoot.make(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    )

    #expect(composition.model.sensorMode == .synthetic)
    #expect(composition.model.sensorAdapter is SyntheticSensorAdapter)
    #expect(composition.model.authorizationSnapshot.readiness == .requestNeeded)
    #expect(composition.model.sessionFixtureAvailable == false)
    #expect(
      composition.model.authorizationSnapshot.observations[.historicalHeartRate]
        == .notInspectable
    )

    let session = MeasurementSession(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000201")!,
      participantID: UUID(uuidString: "00000000-0000-0000-0000-000000000202")!,
      captureIntent: .synthetic,
      state: .recording
    )
    let stream = composition.model.sensorAdapter.batches(
      for: SensorAdapterContext(session: session)
    )
    var iterator = stream.makeAsyncIterator()
    let batch = try await iterator.next()

    #expect(batch?.samples.count == 1)
    #expect(batch?.samples.first?.captureIntent == .synthetic)
    #expect(batch?.samples.first?.acquisitionSource == .synthetic)
    #expect(batch?.samples.first?.provenance.metadata["synthetic"] == "true")
  }

  @Test
  @MainActor
  func defaultCompositionDoesNotReachHealthKit() {
    let composition = PhoneCompositionRoot.make(arguments: [])

    #expect(composition.model.sensorMode == .unavailable)
    #expect(composition.model.sensorAdapter is UnavailableSensorAdapter)
    #expect(composition.model.sessionFixtureAvailable == false)
  }

  @Test
  @MainActor
  func sessionAndSensorFixturesRemainIndependent() {
    let sessionOnly = PhoneCompositionRoot.make(
      arguments: ["COHERENCE_SESSION_FIXTURE=interactive"]
    )
    let sensorOnly = PhoneCompositionRoot.make(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    )

    #expect(sessionOnly.model.sessionFixtureAvailable)
    #expect(sessionOnly.model.sensorMode == .unavailable)
    #expect(sensorOnly.model.sessionFixtureAvailable == false)
    #expect(sensorOnly.model.sensorMode == .synthetic)
  }

  @Test
  @MainActor
  func explicitFixtureRequestRecordsTheRequestWithoutClaimingReadAccess() async {
    let composition = PhoneCompositionRoot.make(
      arguments: [
        AppleRuntimeConfiguration.fakeSensorArgument,
        "COHERENCE_AUTHORIZATION_FIXTURE=needs-request",
      ]
    )

    composition.model.continueFromPrivacy()
    await composition.model.requestAuthorization()

    #expect(composition.model.destination == .overview)
    #expect(composition.model.latestAuthorizationRequest?.result == .completed)
    #expect(composition.model.authorizationSnapshot.readiness == .requestRecorded)
    #expect(
      composition.model.authorizationSnapshot.observations[.historicalHeartRate]
        == .notInspectable
    )
    #expect(composition.model.authorizationErrorCode == nil)
  }

  @Test
  @MainActor
  func diagnosticJSONIsSyntheticAndStructurallyRedacted() async {
    let composition = PhoneCompositionRoot.make(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    )
    await composition.model.requestAuthorization()

    let exportStartedAt = Date()
    let snapshot = composition.model.diagnosticSnapshot
    let exportFinishedAt = Date()
    let json = composition.model.diagnosticJSON

    #expect(snapshot.runIdentifier == AppleRuntimeConfiguration.fixtureRunIdentifier)
    #expect(snapshot.generatedAt >= exportStartedAt)
    #expect(snapshot.generatedAt <= exportFinishedAt)
    #expect(snapshot.authorizationObservedAt == composition.model.authorizationSnapshot.observedAt)
    #expect(snapshot.evidenceSource == "fixture")
    #expect(snapshot.biometricValuesIncluded == false)
    #expect(snapshot.participantIdentityIncluded == false)
    #expect(snapshot.persistentDeviceIdentifierIncluded == false)
    #expect(json.contains("\"biometricValuesIncluded\" : false"))
    #expect(!json.contains("participantID"))
    #expect(!json.contains("SensorSample"))
    #expect(!json.contains("sourceStartTime"))
  }

  @Test
  @MainActor
  func fixtureFailureUsesASanitizedDiagnosticCode() async {
    let composition = PhoneCompositionRoot.make(
      arguments: [
        AppleRuntimeConfiguration.fakeSensorArgument,
        "COHERENCE_AUTHORIZATION_FIXTURE=request-failure",
      ]
    )
    composition.model.continueFromPrivacy()

    await composition.model.requestAuthorization()

    #expect(composition.model.destination == .permissions)
    #expect(composition.model.authorizationErrorCode == "fixture.request-failed")
    #expect(composition.model.latestAuthorizationRequest == nil)
    #expect(composition.model.diagnosticSnapshot.authorizationErrorCode == "fixture.request-failed")
  }

  @Test
  @MainActor
  func requestResultWinsOverAnOlderLaunchRefresh() async {
    let observedAt = AppleRuntimeConfiguration.fixtureTimestamp
    let requestID = UUID(uuidString: "00000000-0000-0000-0000-000000000499")!
    let staleSnapshot = MeasurementAuthorizationSnapshot(
      intents: [.historicalHeartRate],
      readiness: .requestNeeded,
      observations: [.historicalHeartRate: .notInspectable],
      healthDataAvailable: true,
      observedAt: observedAt,
      evidenceSource: .fixture
    )
    let completedSnapshot = MeasurementAuthorizationSnapshot(
      intents: [.historicalHeartRate],
      readiness: .requestRecorded,
      observations: [.historicalHeartRate: .notInspectable],
      healthDataAvailable: true,
      observedAt: observedAt,
      evidenceSource: .fixture,
      latestRequestID: requestID
    )
    let requestRecord = MeasurementAuthorizationRequestRecord(
      id: requestID,
      intents: [.historicalHeartRate],
      requestedAt: observedAt,
      result: .completed
    )
    let service = DelayedRefreshAuthorizationService(
      staleSnapshot: staleSnapshot,
      completedSnapshot: completedSnapshot,
      requestRecord: requestRecord
    )
    let configuration = AppleRuntimeConfiguration(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    )
    let model = PhoneAppModel(
      sensorServices: BootstrapSensorServices(configuration: configuration),
      authorizationServices: BootstrapAuthorizationServices(
        service: service,
        initialSnapshot: staleSnapshot
      ),
      diagnosticContext: AppleDiagnosticContext.current(
        configuration: configuration,
        role: .phone
      ),
      sessionFixtureAvailable: false
    )

    let refresh = Task { await model.refreshAuthorization() }
    await service.waitUntilRefreshIsSuspended()
    await model.requestAuthorization()
    await service.releaseStaleRefresh()
    await refresh.value

    #expect(model.authorizationSnapshot == completedSnapshot)
    #expect(model.latestAuthorizationRequest == requestRecord)
    #expect(model.destination == .overview)
  }

  @Test
  @MainActor
  func diagnosticExportPreservesSanitizedInspectionFailure() {
    let errorCode = "healthkit.authorization-status.7"
    let configuration = AppleRuntimeConfiguration(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    )
    let snapshot = MeasurementAuthorizationSnapshot(
      intents: [.historicalHeartRate],
      readiness: .notRequested,
      observations: [.historicalHeartRate: .notInspectable],
      healthDataAvailable: true,
      observedAt: configuration.observedAt,
      evidenceSource: .fixture,
      inspectionErrorCode: errorCode
    )
    let service = FixtureMeasurementAuthorizationService(
      snapshot: snapshot,
      requestID: UUID(uuidString: "00000000-0000-0000-0000-000000000498")!,
      requestedAt: configuration.observedAt,
      failsRequest: false
    )
    let model = PhoneAppModel(
      sensorServices: BootstrapSensorServices(configuration: configuration),
      authorizationServices: BootstrapAuthorizationServices(
        service: service,
        initialSnapshot: snapshot
      ),
      diagnosticContext: AppleDiagnosticContext.current(
        configuration: configuration,
        role: .phone
      ),
      sessionFixtureAvailable: false
    )

    #expect(model.diagnosticSnapshot.authorizationInspectionErrorCode == errorCode)
    #expect(model.diagnosticJSON.contains(errorCode))
    #expect(model.diagnosticSnapshot.biometricValuesIncluded == false)
  }

  @Test
  func inspectionErrorsRetainKnownCodesAndSanitizePlatformDomains() {
    let knownError = MeasurementAuthorizationServiceError.requestFailed(
      code: "healthkit.heart-rate-type-unavailable"
    )
    let cocoaError = NSError(domain: NSCocoaErrorDomain, code: 513)
    let unknownError = NSError(domain: "participant-name-does-not-belong-here", code: 9)

    #expect(
      HealthKitMeasurementAuthorizationService.inspectionErrorCode(for: knownError)
        == "healthkit.heart-rate-type-unavailable"
    )
    #expect(
      HealthKitMeasurementAuthorizationService.inspectionErrorCode(for: cocoaError)
        == "healthkit.authorization-status.cocoa.513"
    )
    #expect(
      HealthKitMeasurementAuthorizationService.inspectionErrorCode(for: unknownError)
        == "healthkit.authorization-status.platform.9"
    )
  }
}
