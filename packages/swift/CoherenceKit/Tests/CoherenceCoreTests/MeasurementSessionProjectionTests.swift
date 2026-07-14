import Foundation
import XCTest

@testable import CoherenceCore

final class MeasurementSessionProjectionTests: XCTestCase {
  private let sessionID = UUID(uuidString: "00000000-0000-0000-0000-000000000501")!
  private let participantID = UUID(uuidString: "00000000-0000-0000-0000-000000000502")!
  private let sourceDeviceID = UUID(uuidString: "00000000-0000-0000-0000-000000000503")!
  private let timestamp = Date(timeIntervalSince1970: 1_750_000_200)

  func testCompleteSavedLifecycleProjectsDeterministically() throws {
    let projection = try MeasurementSessionProjector.project(
      events: [
        makeEvent(sequence: 1, kind: .prepared(preparation)),
        makeEvent(sequence: 2, kind: .started),
        makeEvent(sequence: 3, kind: .paused),
        makeEvent(sequence: 4, kind: .resumed),
        makeEvent(sequence: 5, kind: .ended),
        makeEvent(sequence: 6, kind: .saved),
      ]
    )

    XCTAssertEqual(projection.session.state, .saved)
    XCTAssertEqual(projection.session.startedAt, timestamp.addingTimeInterval(2))
    XCTAssertEqual(projection.session.endedAt, timestamp.addingTimeInterval(5))
    XCTAssertEqual(projection.latestSequenceNumber, 6)
    XCTAssertEqual(projection.appliedEventCount, 6)
    XCTAssertTrue(projection.availableActions.isEmpty)
  }

  func testPreparedSessionCanBeDiscardedWithoutInventingTimes() throws {
    let projection = try MeasurementSessionProjector.project(
      events: [
        makeEvent(sequence: 1, kind: .prepared(preparation)),
        makeEvent(sequence: 2, kind: .discarded),
      ]
    )

    XCTAssertEqual(projection.session.state, .discarded)
    XCTAssertNil(projection.session.startedAt)
    XCTAssertNil(projection.session.endedAt)
  }

  func testInvalidTransitionIsRejected() {
    XCTAssertThrowsError(
      try MeasurementSessionProjector.project(
        events: [
          makeEvent(sequence: 1, kind: .prepared(preparation)),
          makeEvent(sequence: 2, kind: .saved),
        ]
      )
    )
  }

  func testEventLogMustBeginWithPreparedSequenceOne() {
    XCTAssertThrowsError(try MeasurementSessionProjector.project(events: [])) { error in
      XCTAssertEqual(error as? MeasurementSessionProjectionError, .emptyEventLog)
    }
    XCTAssertThrowsError(
      try MeasurementSessionProjector.project(
        events: [makeEvent(sequence: 1, kind: .started)]
      )
    ) { error in
      XCTAssertEqual(error as? MeasurementSessionProjectionError, .firstEventMustPrepare)
    }
    XCTAssertThrowsError(
      try MeasurementSessionProjector.project(
        events: [makeEvent(sequence: 2, kind: .prepared(preparation))]
      )
    ) { error in
      XCTAssertEqual(
        error as? MeasurementSessionProjectionError,
        .sequenceMustBeginAtOne(actual: 2)
      )
    }
  }

  func testExactDuplicateEventIsIdempotent() throws {
    let prepared = makeEvent(sequence: 1, kind: .prepared(preparation))
    let started = makeEvent(sequence: 2, kind: .started)
    let projection = try MeasurementSessionProjector.project(
      events: [prepared, started, prepared]
    )

    XCTAssertEqual(projection.session.state, .recording)
    XCTAssertEqual(projection.appliedEventCount, 2)
    XCTAssertEqual(projection.latestSequenceNumber, 2)
  }

  func testChangedDuplicateEventIsRejected() {
    let prepared = makeEvent(sequence: 1, kind: .prepared(preparation))
    let changed = MeasurementSessionEvent(
      id: prepared.id,
      sessionID: prepared.sessionID,
      sourceDeviceID: prepared.sourceDeviceID,
      sequenceNumber: prepared.sequenceNumber,
      occurredAt: prepared.occurredAt,
      kind: .discarded
    )

    XCTAssertThrowsError(
      try MeasurementSessionProjector.project(events: [prepared, changed])
    ) { error in
      XCTAssertEqual(
        error as? MeasurementSessionProjectionError,
        .duplicateEventConflict(prepared.id)
      )
    }
  }

  func testSequenceGapAndRegressionAreRejected() {
    let prepared = makeEvent(sequence: 1, kind: .prepared(preparation))

    XCTAssertThrowsError(
      try MeasurementSessionProjector.project(
        events: [prepared, makeEvent(sequence: 3, kind: .started)]
      )
    ) { error in
      XCTAssertEqual(
        error as? MeasurementSessionProjectionError,
        .sequenceGap(expected: 2, actual: 3)
      )
    }

    XCTAssertThrowsError(
      try MeasurementSessionProjector.project(
        events: [
          prepared,
          makeEvent(sequence: 2, kind: .started),
          makeEvent(
            sequence: 1,
            kind: .paused,
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000599")!
          ),
        ]
      )
    ) { error in
      XCTAssertEqual(
        error as? MeasurementSessionProjectionError,
        .sequenceRegression(previous: 2, actual: 1)
      )
    }
  }

  func testMismatchedSessionAndAuthorityAreRejected() {
    let prepared = makeEvent(sequence: 1, kind: .prepared(preparation))
    let wrongSession = MeasurementSessionEvent(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000598")!,
      sessionID: UUID(uuidString: "00000000-0000-0000-0000-000000000597")!,
      sourceDeviceID: sourceDeviceID,
      sequenceNumber: 2,
      occurredAt: clock(sequence: 2),
      kind: .started
    )
    let wrongAuthority = MeasurementSessionEvent(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000596")!,
      sessionID: sessionID,
      sourceDeviceID: UUID(uuidString: "00000000-0000-0000-0000-000000000595")!,
      sequenceNumber: 2,
      occurredAt: clock(sequence: 2),
      kind: .started
    )

    XCTAssertThrowsError(
      try MeasurementSessionProjector.project(events: [prepared, wrongSession])
    )
    XCTAssertThrowsError(
      try MeasurementSessionProjector.project(events: [prepared, wrongAuthority])
    )
  }

  func testInterruptionPausesAndPreservesTypedReason() throws {
    let projection = try MeasurementSessionProjector.project(
      events: [
        makeEvent(sequence: 1, kind: .prepared(preparation)),
        makeEvent(sequence: 2, kind: .started),
        makeEvent(sequence: 3, kind: .interrupted(reason: .sensorUnavailable)),
      ]
    )

    XCTAssertEqual(projection.session.state, .paused)
    XCTAssertEqual(projection.latestInterruptionReason, .sensorUnavailable)
    XCTAssertEqual(projection.availableActions, [.resume, .end])
  }

  func testCodableRoundTripPreservesSavedProjection() throws {
    let projection = try MeasurementSessionProjector.project(
      events: [
        makeEvent(sequence: 1, kind: .prepared(preparation)),
        makeEvent(sequence: 2, kind: .started),
        makeEvent(sequence: 3, kind: .ended),
        makeEvent(sequence: 4, kind: .saved),
      ]
    )

    let data = try JSONEncoder().encode(projection)
    let decoded = try JSONDecoder().decode(MeasurementSessionProjection.self, from: data)

    XCTAssertEqual(decoded, projection)
    XCTAssertEqual(decoded.session.state, .saved)
  }

  func testReplayIsDeterministicAndTerminalStateRejectsMutation() throws {
    let events = [
      makeEvent(sequence: 1, kind: .prepared(preparation)),
      makeEvent(sequence: 2, kind: .started),
      makeEvent(sequence: 3, kind: .ended),
      makeEvent(sequence: 4, kind: .saved),
    ]

    XCTAssertEqual(
      try MeasurementSessionProjector.project(events: events),
      try MeasurementSessionProjector.project(events: events)
    )
    XCTAssertThrowsError(
      try MeasurementSessionProjector.project(
        events: events + [makeEvent(sequence: 5, kind: .paused)]
      )
    )
  }

  private var preparation: MeasurementSessionPreparation {
    MeasurementSessionPreparation(
      participantID: participantID,
      activityLabel: "Synthetic rehearsal",
      captureIntent: .synthetic
    )
  }

  private func makeEvent(
    sequence: UInt64,
    kind: MeasurementSessionEventKind,
    id: UUID? = nil
  ) -> MeasurementSessionEvent {
    MeasurementSessionEvent(
      id: id ?? UUID(
        uuidString: String(
          format: "00000000-0000-0000-0000-%012llx",
          0x510 + sequence
        )
      )!,
      sessionID: sessionID,
      sourceDeviceID: sourceDeviceID,
      sequenceNumber: sequence,
      occurredAt: clock(sequence: sequence),
      kind: kind
    )
  }

  private func clock(sequence: UInt64) -> ClockContext {
    ClockContext(
      deviceWallTime: timestamp.addingTimeInterval(TimeInterval(sequence)),
      timeZoneIdentifier: "UTC"
    )
  }
}
