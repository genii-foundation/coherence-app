import CoherenceAcquisition
import CoherenceCore
import Foundation
import Testing

@testable import CoherenceWatchApp

struct WatchCompositionTests {
  @Test
  @MainActor
  func fakeArgumentSelectsSyntheticAdapter() async throws {
    let composition = WatchCompositionRoot.make(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    )

    #expect(composition.model.sensorMode == .synthetic)
    #expect(composition.model.sensorAdapter is SyntheticSensorAdapter)
    #expect(composition.model.sensorMode.displayName == "Synthetic sensors active")
    #expect(composition.model.authorizationSnapshot.readiness == .requestNeeded)

    let session = MeasurementSession(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000301")!,
      participantID: UUID(uuidString: "00000000-0000-0000-0000-000000000302")!,
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
  func defaultCompositionUsesUnavailableAdapter() {
    let composition = WatchCompositionRoot.make(arguments: [])

    #expect(composition.model.sensorMode == .unavailable)
    #expect(composition.model.sensorAdapter is UnavailableSensorAdapter)
  }

  @Test
  @MainActor
  func prepareMeasurementRecordsARequestWithoutClaimingReadAuthorization() async {
    let composition = WatchCompositionRoot.make(
      arguments: [
        AppleRuntimeConfiguration.fakeSensorArgument,
        "COHERENCE_AUTHORIZATION_FIXTURE=needs-request",
      ]
    )

    await composition.model.prepareMeasurement()

    #expect(composition.model.authorizationSnapshot.readiness == .requestRecorded)
    #expect(composition.model.latestAuthorizationRequest?.result == .completed)
    #expect(
      composition.model.authorizationSnapshot.observations[.liveHeartRate]
        == .notInspectable
    )
    #expect(
      composition.model.authorizationSnapshot.observations[.workoutRecording]
        == .authorized
    )
    #expect(composition.model.authorizationErrorCode == nil)
  }

  @Test
  @MainActor
  func fixtureReadinessProjectsDeterministically() {
    let scenarios: [(String, MeasurementAuthorizationReadiness)] = [
      ("COHERENCE_AUTHORIZATION_FIXTURE=unavailable", .unavailable),
      ("COHERENCE_AUTHORIZATION_FIXTURE=needs-companion", .needsCompanion),
      ("COHERENCE_AUTHORIZATION_FIXTURE=write-denied", .requestRecorded),
    ]

    for (argument, expected) in scenarios {
      let composition = WatchCompositionRoot.make(
        arguments: [AppleRuntimeConfiguration.fakeSensorArgument, argument]
      )
      #expect(composition.model.authorizationSnapshot.readiness == expected)
    }

    let writeDenied = WatchCompositionRoot.make(
      arguments: [
        AppleRuntimeConfiguration.fakeSensorArgument,
        "COHERENCE_AUTHORIZATION_FIXTURE=write-denied",
      ]
    )
    #expect(
      writeDenied.model.authorizationSnapshot.observations[.workoutRecording] == .denied
    )
  }

  @Test
  @MainActor
  func requestFailureIsSanitized() async {
    let composition = WatchCompositionRoot.make(
      arguments: [
        AppleRuntimeConfiguration.fakeSensorArgument,
        "COHERENCE_AUTHORIZATION_FIXTURE=request-failure",
      ]
    )

    await composition.model.prepareMeasurement()

    #expect(composition.model.authorizationErrorCode == "fixture.request-failed")
    #expect(composition.model.latestAuthorizationRequest == nil)
  }
}
