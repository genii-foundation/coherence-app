import Foundation

public enum MeasurementSessionInterruptionReason: String, Codable, Equatable, Sendable {
  case system
  case sensorUnavailable
  case sourceDisconnected
  case unknown
}

public struct MeasurementSessionPreparation: Codable, Equatable, Sendable {
  public let participantID: UUID
  public let eventID: UUID?
  public let activityLabel: String?
  public let captureIntent: CaptureIntent

  public init(
    participantID: UUID,
    eventID: UUID? = nil,
    activityLabel: String? = nil,
    captureIntent: CaptureIntent
  ) {
    self.participantID = participantID
    self.eventID = eventID
    self.activityLabel = activityLabel
    self.captureIntent = captureIntent
  }
}

public enum MeasurementSessionEventKind: Codable, Equatable, Sendable {
  case prepared(MeasurementSessionPreparation)
  case started
  case paused
  case resumed
  case ended
  case saved
  case discarded
  case interrupted(reason: MeasurementSessionInterruptionReason)
}

public struct MeasurementSessionEvent: Identifiable, Codable, Equatable, Sendable {
  public let id: UUID
  public let sessionID: UUID
  public let sourceDeviceID: UUID
  public let sequenceNumber: UInt64
  public let occurredAt: ClockContext
  public let kind: MeasurementSessionEventKind

  public init(
    id: UUID,
    sessionID: UUID,
    sourceDeviceID: UUID,
    sequenceNumber: UInt64,
    occurredAt: ClockContext,
    kind: MeasurementSessionEventKind
  ) {
    self.id = id
    self.sessionID = sessionID
    self.sourceDeviceID = sourceDeviceID
    self.sequenceNumber = sequenceNumber
    self.occurredAt = occurredAt
    self.kind = kind
  }
}
