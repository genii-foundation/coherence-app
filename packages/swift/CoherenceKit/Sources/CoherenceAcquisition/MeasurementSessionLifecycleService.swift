import CoherenceCore

public enum MeasurementSessionCommand: Equatable, Sendable {
  case prepare(MeasurementSessionPreparation)
  case start
  case pause
  case resume
  case end
  case save
  case discard
  case interrupt(MeasurementSessionInterruptionReason)
}

public struct MeasurementSessionTransition: Equatable, Sendable {
  public let event: MeasurementSessionEvent
  public let projection: MeasurementSessionProjection

  public init(
    event: MeasurementSessionEvent,
    projection: MeasurementSessionProjection
  ) {
    self.event = event
    self.projection = projection
  }
}

public enum MeasurementSessionLifecycleServiceError: Error, Equatable, Sendable {
  case noSession
  case activeSession
  case invalidTransition
  case projectionFailed
}

public protocol MeasurementSessionLifecycleService: Sendable {
  func currentProjection() async throws -> MeasurementSessionProjection?
  func perform(_ command: MeasurementSessionCommand) async throws
    -> MeasurementSessionTransition
}
