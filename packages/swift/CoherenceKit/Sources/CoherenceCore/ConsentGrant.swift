import Foundation

public enum ConsentDataClass: String, Codable, Equatable, Hashable, Sendable {
  case healthHistory
  case liveHeartRate
  case motion
  case externalHeartSensor
  case derivedFeatures
  case groupAggregates
}

public enum ConsentVisibility: String, Codable, Equatable, Sendable {
  case participantOnly
  case aggregateOnly
  case namedIndividual
}

public enum ConsentRepresentation: String, Codable, Equatable, Hashable, Sendable {
  case raw
  case normalized
  case derived
}

public enum ConsentRetention: Codable, Equatable, Sendable {
  case untilRevoked
  case until(Date)
  case durationDays(Int)
}

public struct ConsentGrant: Identifiable, Codable, Equatable, Sendable {
  public let id: UUID
  public let participantID: UUID
  public let eventID: UUID?
  public let sessionID: UUID?
  public let dataClasses: Set<ConsentDataClass>
  public let captureIntents: Set<CaptureIntent>
  public let representations: Set<ConsentRepresentation>
  public let purpose: String
  public let visibility: ConsentVisibility
  public let retention: ConsentRetention
  public let allowsResearchUse: Bool
  public let allowsModelTraining: Bool
  public let policyVersion: String
  public let grantedAt: Date
  public let expiresAt: Date?
  public let revokedAt: Date?

  public init(
    id: UUID,
    participantID: UUID,
    eventID: UUID? = nil,
    sessionID: UUID? = nil,
    dataClasses: Set<ConsentDataClass>,
    captureIntents: Set<CaptureIntent>,
    representations: Set<ConsentRepresentation>,
    purpose: String,
    visibility: ConsentVisibility,
    retention: ConsentRetention,
    allowsResearchUse: Bool = false,
    allowsModelTraining: Bool = false,
    policyVersion: String,
    grantedAt: Date,
    expiresAt: Date? = nil,
    revokedAt: Date? = nil
  ) {
    self.id = id
    self.participantID = participantID
    self.eventID = eventID
    self.sessionID = sessionID
    self.dataClasses = dataClasses
    self.captureIntents = captureIntents
    self.representations = representations
    self.purpose = purpose
    self.visibility = visibility
    self.retention = retention
    self.allowsResearchUse = allowsResearchUse
    self.allowsModelTraining = allowsModelTraining
    self.policyVersion = policyVersion
    self.grantedAt = grantedAt
    self.expiresAt = expiresAt
    self.revokedAt = revokedAt
  }
}
