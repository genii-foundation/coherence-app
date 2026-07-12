import CoherenceAcquisition
import CoherenceCore
import Foundation
import Testing

@testable import CoherenceApp

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

    let snapshot = composition.model.diagnosticSnapshot
    let json = composition.model.diagnosticJSON

    #expect(snapshot.runIdentifier == AppleRuntimeConfiguration.fixtureRunIdentifier)
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
}
