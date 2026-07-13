import CoherenceAcquisition
import CoherenceCore
import Foundation

struct BootstrapSessionServices: Sendable {
  let service: (any MeasurementSessionLifecycleService)?

  init(configuration: AppleRuntimeConfiguration) {
    #if DEBUG
      service = configuration.sessionFixture == .interactive
        ? FixtureMeasurementSessionLifecycleService()
        : nil
    #else
      service = nil
    #endif
  }
}

#if DEBUG
  actor FixtureMeasurementSessionLifecycleService: MeasurementSessionLifecycleService {
    private static let authorityDeviceID = UUID(
      uuidString: "00000000-0000-0000-0000-000000000601"
    )!
    private static let fixtureTimestamp = Date(timeIntervalSince1970: 1_750_000_300)

    private var events: [MeasurementSessionEvent] = []
    private var terminalEventLogs: [[MeasurementSessionEvent]] = []
    private var generation: UInt64 = 0

    init(events: [MeasurementSessionEvent] = []) {
      self.events = events
    }

    func currentProjection() throws -> MeasurementSessionProjection? {
      guard !events.isEmpty else {
        return nil
      }
      return try MeasurementSessionProjector.project(events: events)
    }

    func perform(
      _ command: MeasurementSessionCommand
    ) throws -> MeasurementSessionTransition {
      if case .prepare = command {
        return try prepare(command)
      }

      guard let projection = try currentProjection() else {
        throw MeasurementSessionLifecycleServiceError.noSession
      }
      let kind = eventKind(for: command)
      let event = makeEvent(
        sessionID: projection.session.id,
        sequenceNumber: projection.latestSequenceNumber + 1,
        kind: kind
      )
      let candidateEvents = events + [event]
      let candidateProjection: MeasurementSessionProjection
      do {
        candidateProjection = try MeasurementSessionProjector.project(events: candidateEvents)
      } catch is MeasurementSessionProjectionError {
        throw MeasurementSessionLifecycleServiceError.invalidTransition
      }
      events = candidateEvents
      return MeasurementSessionTransition(
        event: event,
        projection: candidateProjection
      )
    }

    private func prepare(
      _ command: MeasurementSessionCommand
    ) throws -> MeasurementSessionTransition {
      if let projection = try currentProjection(),
        projection.session.state != .saved,
        projection.session.state != .discarded
      {
        throw MeasurementSessionLifecycleServiceError.activeSession
      }
      guard case .prepare(let preparation) = command else {
        throw MeasurementSessionLifecycleServiceError.projectionFailed
      }

      generation += 1
      if !events.isEmpty {
        terminalEventLogs.append(events)
      }
      let sessionID = Self.deterministicUUID(value: 0x610 + generation)
      let event = makeEvent(
        sessionID: sessionID,
        sequenceNumber: 1,
        kind: .prepared(preparation)
      )
      let projection: MeasurementSessionProjection
      do {
        projection = try MeasurementSessionProjector.project(events: [event])
      } catch {
        throw MeasurementSessionLifecycleServiceError.projectionFailed
      }
      events = [event]
      return MeasurementSessionTransition(event: event, projection: projection)
    }

    func retainedTerminalSessionCount() -> Int {
      terminalEventLogs.count
    }

    func currentEventCount() -> Int {
      events.count
    }

    private func eventKind(
      for command: MeasurementSessionCommand
    ) -> MeasurementSessionEventKind {
      switch command {
      case .prepare:
        preconditionFailure("Prepare is handled before event mapping")
      case .start:
        .started
      case .pause:
        .paused
      case .resume:
        .resumed
      case .end:
        .ended
      case .save:
        .saved
      case .discard:
        .discarded
      case .interrupt(let reason):
        .interrupted(reason: reason)
      }
    }

    private func makeEvent(
      sessionID: UUID,
      sequenceNumber: UInt64,
      kind: MeasurementSessionEventKind
    ) -> MeasurementSessionEvent {
      MeasurementSessionEvent(
        id: Self.deterministicUUID(
          value: 0x700 + (generation * 0x100) + sequenceNumber
        ),
        sessionID: sessionID,
        sourceDeviceID: Self.authorityDeviceID,
        sequenceNumber: sequenceNumber,
        occurredAt: ClockContext(
          deviceWallTime: Self.fixtureTimestamp.addingTimeInterval(
            TimeInterval((generation * 100) + sequenceNumber)
          ),
          timeZoneIdentifier: "UTC"
        ),
        kind: kind
      )
    }

    private static func deterministicUUID(value: UInt64) -> UUID {
      UUID(
        uuidString: String(
          format: "00000000-0000-0000-0000-%012llx",
          value
        )
      )!
    }
  }
#endif
