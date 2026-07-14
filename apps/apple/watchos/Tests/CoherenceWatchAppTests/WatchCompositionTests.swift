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
    #expect(composition.model.sessionFixtureAvailable == false)

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
    #expect(composition.model.sessionFixtureAvailable == false)
  }

  @Test
  @MainActor
  func requestMeasurementAccessRecordsARequestWithoutClaimingReadAuthorization() async {
    let composition = WatchCompositionRoot.make(
      arguments: [
        AppleRuntimeConfiguration.fakeSensorArgument,
        "COHERENCE_AUTHORIZATION_FIXTURE=needs-request",
      ]
    )

    await composition.model.requestMeasurementAccess()

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

    await composition.model.requestMeasurementAccess()

    #expect(composition.model.authorizationErrorCode == "fixture.request-failed")
    #expect(composition.model.latestAuthorizationRequest == nil)
  }

  @Test
  @MainActor
  func interactiveFixtureExercisesTheCompleteSavedLifecycle() async {
    let composition = WatchCompositionRoot.make(
      arguments: [
        AppleRuntimeConfiguration.fakeSensorArgument,
        "COHERENCE_AUTHORIZATION_FIXTURE=request-recorded",
        "COHERENCE_SESSION_FIXTURE=interactive",
      ]
    )

    #expect(composition.model.sessionFixtureAvailable)
    #expect(composition.model.sessionProjection == nil)

    await composition.model.startSyntheticRehearsal()
    #expect(composition.model.sessionProjection?.session.state == .recording)
    #expect(composition.model.sessionProjection?.appliedEventCount == 2)
    #expect(composition.model.sessionProjection?.availableActions == [.pause, .end])

    await composition.model.pauseSyntheticRehearsal()
    #expect(composition.model.sessionProjection?.session.state == .paused)

    await composition.model.resumeSyntheticRehearsal()
    #expect(composition.model.sessionProjection?.session.state == .recording)

    await composition.model.endSyntheticRehearsal()
    #expect(composition.model.sessionProjection?.session.state == .ended)

    await composition.model.saveSyntheticRehearsal()
    #expect(composition.model.sessionProjection?.session.state == .saved)
    #expect(composition.model.sessionProjection?.appliedEventCount == 6)
    #expect(composition.model.sessionErrorCode == nil)
  }

  @Test
  @MainActor
  func discardAndRestartRemainDistinctDeterministicRuns() async {
    let composition = WatchCompositionRoot.make(
      arguments: ["COHERENCE_SESSION_FIXTURE=interactive"]
    )

    await composition.model.startSyntheticRehearsal()
    let firstSessionID = composition.model.sessionProjection?.session.id
    await composition.model.endSyntheticRehearsal()
    await composition.model.discardSyntheticRehearsal()

    #expect(composition.model.sensorMode == .unavailable)
    #expect(composition.model.sessionProjection?.session.state == .discarded)

    await composition.model.startSyntheticRehearsal()

    #expect(composition.model.sessionProjection?.session.state == .recording)
    #expect(composition.model.sessionProjection?.session.id != firstSessionID)
    #expect(composition.model.sessionProjection?.appliedEventCount == 2)
  }

  @Test
  @MainActor
  func authorizationRequestDoesNotCreateASession() async {
    let composition = WatchCompositionRoot.make(
      arguments: [
        AppleRuntimeConfiguration.fakeSensorArgument,
        "COHERENCE_AUTHORIZATION_FIXTURE=needs-request",
        "COHERENCE_SESSION_FIXTURE=interactive",
      ]
    )

    await composition.model.requestMeasurementAccess()

    #expect(composition.model.latestAuthorizationRequest?.result == .completed)
    #expect(composition.model.sessionProjection == nil)
  }

  @Test
  @MainActor
  func invalidLifecycleCommandFailsWithoutInventingASession() async {
    let composition = WatchCompositionRoot.make(
      arguments: ["COHERENCE_SESSION_FIXTURE=interactive"]
    )

    await composition.model.pauseSyntheticRehearsal()

    #expect(composition.model.sessionProjection == nil)
    #expect(composition.model.sessionErrorCode == "session.not-prepared")
  }

  @Test
  @MainActor
  func repeatedStartIntentProducesOnePreparedAndOneStartedEvent() async {
    let composition = WatchCompositionRoot.make(
      arguments: ["COHERENCE_SESSION_FIXTURE=interactive"]
    )

    async let first: Void = composition.model.startSyntheticRehearsal()
    async let second: Void = composition.model.startSyntheticRehearsal()
    _ = await (first, second)

    #expect(composition.model.sessionProjection?.session.state == .recording)
    #expect(composition.model.sessionProjection?.appliedEventCount == 2)
    #expect(composition.model.sessionErrorCode == nil)
  }

  @Test
  func fixturePreservesCorruptReplayEvidence() async {
    let sessionID = UUID(uuidString: "00000000-0000-0000-0000-000000000680")!
    let corruptEvent = MeasurementSessionEvent(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000681")!,
      sessionID: sessionID,
      sourceDeviceID: UUID(uuidString: "00000000-0000-0000-0000-000000000682")!,
      sequenceNumber: 2,
      occurredAt: ClockContext(
        deviceWallTime: Date(timeIntervalSince1970: 1_750_000_400),
        timeZoneIdentifier: "UTC"
      ),
      kind: .prepared(
        MeasurementSessionPreparation(
          participantID: UUID(
            uuidString: "00000000-0000-0000-0000-000000000683"
          )!,
          captureIntent: .synthetic
        )
      )
    )
    let service = FixtureMeasurementSessionLifecycleService(events: [corruptEvent])
    var replayError: MeasurementSessionProjectionError?
    var prepareError: MeasurementSessionProjectionError?

    do {
      _ = try await service.currentProjection()
    } catch let error as MeasurementSessionProjectionError {
      replayError = error
    } catch {}

    do {
      _ = try await service.perform(
        .prepare(
          MeasurementSessionPreparation(
            participantID: UUID(
              uuidString: "00000000-0000-0000-0000-000000000684"
            )!,
            captureIntent: .synthetic
          )
        )
      )
    } catch let error as MeasurementSessionProjectionError {
      prepareError = error
    } catch {}

    #expect(replayError == .sequenceMustBeginAtOne(actual: 2))
    #expect(prepareError == .sequenceMustBeginAtOne(actual: 2))
    #expect(await service.currentEventCount() == 1)
  }

  @Test
  func fixtureRetainsTerminalLogWhenARehearsalRestarts() async throws {
    let service = FixtureMeasurementSessionLifecycleService()
    let preparation = MeasurementSessionPreparation(
      participantID: UUID(uuidString: "00000000-0000-0000-0000-000000000690")!,
      captureIntent: .synthetic
    )

    _ = try await service.perform(.prepare(preparation))
    _ = try await service.perform(.start)
    _ = try await service.perform(.end)
    _ = try await service.perform(.save)
    _ = try await service.perform(.prepare(preparation))

    #expect(await service.retainedTerminalSessionCount() == 1)
    #expect(await service.currentEventCount() == 1)
    #expect(try await service.currentProjection()?.session.state == .prepared)
  }
}
