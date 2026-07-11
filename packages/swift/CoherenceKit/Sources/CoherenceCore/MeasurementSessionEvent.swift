import Foundation

public enum MeasurementSessionEventKind: Codable, Equatable, Sendable {
  case prepared
  case started
  case paused
  case resumed
  case ended
  case saved
  case discarded
  case interrupted(reason: String)
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
