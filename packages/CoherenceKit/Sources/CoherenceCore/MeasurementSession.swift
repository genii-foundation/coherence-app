import Foundation

public enum MeasurementCollectionMode: String, Codable, Equatable, Hashable, Sendable {
  case passive
  case explicitWatch
  case externalSensor
}

public enum MeasurementSessionState: String, Codable, Equatable, Sendable {
  case prepared
  case recording
  case paused
  case ended
  case discarded
}

public struct MeasurementSession: Identifiable, Codable, Equatable, Sendable {
  public let id: UUID
  public let participantID: UUID
  public let eventID: UUID?
  public let activityLabel: String?
  public let collectionMode: MeasurementCollectionMode
  public let state: MeasurementSessionState
  public let startedAt: Date?
  public let endedAt: Date?

  public init(
    id: UUID,
    participantID: UUID,
    eventID: UUID? = nil,
    activityLabel: String? = nil,
    collectionMode: MeasurementCollectionMode,
    state: MeasurementSessionState,
    startedAt: Date? = nil,
    endedAt: Date? = nil
  ) {
    self.id = id
    self.participantID = participantID
    self.eventID = eventID
    self.activityLabel = activityLabel
    self.collectionMode = collectionMode
    self.state = state
    self.startedAt = startedAt
    self.endedAt = endedAt
  }
}
