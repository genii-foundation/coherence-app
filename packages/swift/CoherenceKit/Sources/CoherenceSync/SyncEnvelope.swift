import CoherenceCore
import Foundation

public struct DeletionRequest: Identifiable, Codable, Equatable, Sendable {
  public let id: UUID
  public let participantID: UUID
  public let eventID: UUID?
  public let sessionID: UUID?
  public let dataClasses: Set<ConsentDataClass>
  public let representations: Set<ConsentRepresentation>
  public let requestedAt: Date

  public init(
    id: UUID,
    participantID: UUID,
    eventID: UUID? = nil,
    sessionID: UUID? = nil,
    dataClasses: Set<ConsentDataClass>,
    representations: Set<ConsentRepresentation>,
    requestedAt: Date
  ) {
    self.id = id
    self.participantID = participantID
    self.eventID = eventID
    self.sessionID = sessionID
    self.dataClasses = dataClasses
    self.representations = representations
    self.requestedAt = requestedAt
  }
}

public enum SyncPayload: Codable, Equatable, Sendable {
  case sampleBatch(SampleBatch)
  case acknowledgement(batchID: UUID, receivedAt: Date)
  case deletionRequest(DeletionRequest)
  case deletionAcknowledgement(requestID: UUID, completedAt: Date)
}

public struct SyncEnvelope: Identifiable, Codable, Equatable, Sendable {
  public let id: UUID
  public let senderDeviceID: UUID
  public let createdAt: Date
  public let protocolVersion: Int
  public let payload: SyncPayload

  public init(
    id: UUID,
    senderDeviceID: UUID,
    createdAt: Date,
    protocolVersion: Int = 1,
    payload: SyncPayload
  ) {
    self.id = id
    self.senderDeviceID = senderDeviceID
    self.createdAt = createdAt
    self.protocolVersion = protocolVersion
    self.payload = payload
  }
}
