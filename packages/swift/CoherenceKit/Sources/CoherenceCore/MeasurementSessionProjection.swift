import Foundation

public enum MeasurementSessionAction: String, Codable, Hashable, Sendable {
  case start
  case pause
  case resume
  case end
  case save
  case discard
}

public enum MeasurementSessionProjectionError: Error, Equatable, Sendable {
  case emptyEventLog
  case firstEventMustPrepare
  case sequenceMustBeginAtOne(actual: UInt64)
  case sequenceGap(expected: UInt64, actual: UInt64)
  case sequenceRegression(previous: UInt64, actual: UInt64)
  case duplicateEventConflict(UUID)
  case sessionIDMismatch(expected: UUID, actual: UUID)
  case authorityDeviceMismatch(expected: UUID, actual: UUID)
  case invalidTransition(
    state: MeasurementSessionState,
    event: MeasurementSessionEventKind
  )
}

public struct MeasurementSessionProjection: Codable, Equatable, Sendable {
  public let session: MeasurementSession
  public let authorityDeviceID: UUID
  public let latestSequenceNumber: UInt64
  public let appliedEventCount: Int
  public let latestInterruptionReason: MeasurementSessionInterruptionReason?

  public init(
    session: MeasurementSession,
    authorityDeviceID: UUID,
    latestSequenceNumber: UInt64,
    appliedEventCount: Int,
    latestInterruptionReason: MeasurementSessionInterruptionReason? = nil
  ) {
    self.session = session
    self.authorityDeviceID = authorityDeviceID
    self.latestSequenceNumber = latestSequenceNumber
    self.appliedEventCount = appliedEventCount
    self.latestInterruptionReason = latestInterruptionReason
  }

  public var availableActions: Set<MeasurementSessionAction> {
    switch session.state {
    case .prepared:
      [.start, .discard]
    case .recording:
      [.pause, .end]
    case .paused:
      [.resume, .end]
    case .ended:
      [.save, .discard]
    case .saved, .discarded:
      []
    }
  }
}

public enum MeasurementSessionProjector {
  public static func project(
    events: [MeasurementSessionEvent]
  ) throws -> MeasurementSessionProjection {
    guard let firstEvent = events.first else {
      throw MeasurementSessionProjectionError.emptyEventLog
    }
    guard case .prepared(let preparation) = firstEvent.kind else {
      throw MeasurementSessionProjectionError.firstEventMustPrepare
    }
    guard firstEvent.sequenceNumber == 1 else {
      throw MeasurementSessionProjectionError.sequenceMustBeginAtOne(
        actual: firstEvent.sequenceNumber
      )
    }

    let sessionID = firstEvent.sessionID
    let authorityDeviceID = firstEvent.sourceDeviceID
    var session = MeasurementSession(
      id: sessionID,
      participantID: preparation.participantID,
      eventID: preparation.eventID,
      activityLabel: preparation.activityLabel,
      captureIntent: preparation.captureIntent,
      state: .prepared
    )
    var latestInterruptionReason: MeasurementSessionInterruptionReason?
    var latestSequenceNumber: UInt64 = 0
    var appliedEventCount = 0
    var eventsByID: [UUID: MeasurementSessionEvent] = [:]

    for event in events {
      if let existingEvent = eventsByID[event.id] {
        guard existingEvent == event else {
          throw MeasurementSessionProjectionError.duplicateEventConflict(event.id)
        }
        continue
      }

      guard event.sessionID == sessionID else {
        throw MeasurementSessionProjectionError.sessionIDMismatch(
          expected: sessionID,
          actual: event.sessionID
        )
      }
      guard event.sourceDeviceID == authorityDeviceID else {
        throw MeasurementSessionProjectionError.authorityDeviceMismatch(
          expected: authorityDeviceID,
          actual: event.sourceDeviceID
        )
      }

      let expectedSequenceNumber = latestSequenceNumber + 1
      if event.sequenceNumber < expectedSequenceNumber {
        throw MeasurementSessionProjectionError.sequenceRegression(
          previous: latestSequenceNumber,
          actual: event.sequenceNumber
        )
      }
      if event.sequenceNumber > expectedSequenceNumber {
        throw MeasurementSessionProjectionError.sequenceGap(
          expected: expectedSequenceNumber,
          actual: event.sequenceNumber
        )
      }

      if appliedEventCount == 0 {
        guard case .prepared = event.kind else {
          throw MeasurementSessionProjectionError.firstEventMustPrepare
        }
      } else {
        let nextState = try projectedState(
          from: session.state,
          event: event.kind
        )
        session = MeasurementSession(
          id: session.id,
          participantID: session.participantID,
          eventID: session.eventID,
          activityLabel: session.activityLabel,
          captureIntent: session.captureIntent,
          state: nextState,
          startedAt: projectedStartTime(session: session, event: event),
          endedAt: projectedEndTime(session: session, event: event)
        )
        if case .interrupted(let reason) = event.kind {
          latestInterruptionReason = reason
        }
      }

      eventsByID[event.id] = event
      latestSequenceNumber = event.sequenceNumber
      appliedEventCount += 1
    }

    return MeasurementSessionProjection(
      session: session,
      authorityDeviceID: authorityDeviceID,
      latestSequenceNumber: latestSequenceNumber,
      appliedEventCount: appliedEventCount,
      latestInterruptionReason: latestInterruptionReason
    )
  }

  private static func projectedState(
    from state: MeasurementSessionState,
    event: MeasurementSessionEventKind
  ) throws -> MeasurementSessionState {
    switch (state, event) {
    case (.prepared, .started):
      .recording
    case (.prepared, .discarded):
      .discarded
    case (.recording, .paused):
      .paused
    case (.paused, .resumed):
      .recording
    case (.recording, .ended), (.paused, .ended):
      .ended
    case (.ended, .saved):
      .saved
    case (.ended, .discarded):
      .discarded
    case (.recording, .interrupted):
      .paused
    default:
      throw MeasurementSessionProjectionError.invalidTransition(
        state: state,
        event: event
      )
    }
  }

  private static func projectedStartTime(
    session: MeasurementSession,
    event: MeasurementSessionEvent
  ) -> Date? {
    if case .started = event.kind {
      return session.startedAt ?? event.occurredAt.deviceWallTime
    }
    return session.startedAt
  }

  private static func projectedEndTime(
    session: MeasurementSession,
    event: MeasurementSessionEvent
  ) -> Date? {
    if case .ended = event.kind {
      return session.endedAt ?? event.occurredAt.deviceWallTime
    }
    return session.endedAt
  }
}
