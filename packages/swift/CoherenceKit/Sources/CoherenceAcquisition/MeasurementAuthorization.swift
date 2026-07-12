import Foundation

public enum MeasurementAuthorizationIntent: String, CaseIterable, Codable, Hashable, Sendable {
  case historicalHeartRate
  case historicalHeartRateVariability
  case liveHeartRate
  case workoutRecording
}

public enum MeasurementAuthorizationReadiness: String, Codable, Equatable, Sendable {
  case notRequested
  case requestNeeded
  case requestRecorded
  case unavailable
  case needsCompanion
}

public enum MeasurementAuthorizationObservation: String, Codable, Equatable, Sendable {
  case notInspectable
  case notDetermined
  case denied
  case authorized
  case notApplicable
}

public enum MeasurementAuthorizationEvidenceSource: String, Codable, Equatable, Sendable {
  case fixture
  case simulator
  case physicalDevice
  case unavailable
}

public struct MeasurementAuthorizationSnapshot: Codable, Equatable, Sendable {
  public let intents: Set<MeasurementAuthorizationIntent>
  public let readiness: MeasurementAuthorizationReadiness
  public let observations: [MeasurementAuthorizationIntent: MeasurementAuthorizationObservation]
  public let healthDataAvailable: Bool
  public let observedAt: Date
  public let evidenceSource: MeasurementAuthorizationEvidenceSource
  public let latestRequestID: UUID?

  public init(
    intents: Set<MeasurementAuthorizationIntent>,
    readiness: MeasurementAuthorizationReadiness,
    observations: [MeasurementAuthorizationIntent: MeasurementAuthorizationObservation],
    healthDataAvailable: Bool,
    observedAt: Date,
    evidenceSource: MeasurementAuthorizationEvidenceSource,
    latestRequestID: UUID? = nil
  ) {
    self.intents = intents
    self.readiness = readiness
    self.observations = observations
    self.healthDataAvailable = healthDataAvailable
    self.observedAt = observedAt
    self.evidenceSource = evidenceSource
    self.latestRequestID = latestRequestID
  }
}

public enum MeasurementAuthorizationRequestResult: String, Codable, Equatable, Sendable {
  case completed
}

public struct MeasurementAuthorizationRequestRecord: Identifiable, Codable, Equatable, Sendable {
  public let id: UUID
  public let intents: Set<MeasurementAuthorizationIntent>
  public let requestedAt: Date
  public let result: MeasurementAuthorizationRequestResult

  public init(
    id: UUID,
    intents: Set<MeasurementAuthorizationIntent>,
    requestedAt: Date,
    result: MeasurementAuthorizationRequestResult
  ) {
    self.id = id
    self.intents = intents
    self.requestedAt = requestedAt
    self.result = result
  }
}

public enum MeasurementAuthorizationServiceError: Error, Equatable, Sendable {
  case unavailable
  case needsCompanion
  case requestFailed(code: String)
}

public protocol MeasurementAuthorizationService: Sendable {
  func currentSnapshot() async -> MeasurementAuthorizationSnapshot
  func requestAuthorization() async throws -> MeasurementAuthorizationRequestRecord
}
