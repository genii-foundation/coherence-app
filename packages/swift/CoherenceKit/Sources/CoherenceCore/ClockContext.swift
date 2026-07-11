import Foundation

public struct MonotonicInstant: Codable, Equatable, Sendable {
  public let clockIdentifier: String
  public let ticks: UInt64
  public let ticksPerSecond: UInt64

  public init(clockIdentifier: String, ticks: UInt64, ticksPerSecond: UInt64) {
    self.clockIdentifier = clockIdentifier
    self.ticks = ticks
    self.ticksPerSecond = ticksPerSecond
  }
}

public struct ClockOffsetEstimate: Codable, Equatable, Sendable {
  public let referenceClockIdentifier: String
  public let offsetSeconds: Double
  public let roundTripSeconds: Double
  public let uncertaintySeconds: Double
  public let measuredAt: Date
  public let validUntil: Date?

  public init(
    referenceClockIdentifier: String,
    offsetSeconds: Double,
    roundTripSeconds: Double,
    uncertaintySeconds: Double,
    measuredAt: Date,
    validUntil: Date? = nil
  ) {
    self.referenceClockIdentifier = referenceClockIdentifier
    self.offsetSeconds = offsetSeconds
    self.roundTripSeconds = roundTripSeconds
    self.uncertaintySeconds = uncertaintySeconds
    self.measuredAt = measuredAt
    self.validUntil = validUntil
  }
}

public struct ClockContext: Codable, Equatable, Sendable {
  public let deviceWallTime: Date
  public let monotonicInstant: MonotonicInstant?
  public let offsetEstimates: [ClockOffsetEstimate]
  public let timeZoneIdentifier: String

  public init(
    deviceWallTime: Date,
    monotonicInstant: MonotonicInstant? = nil,
    offsetEstimates: [ClockOffsetEstimate] = [],
    timeZoneIdentifier: String
  ) {
    self.deviceWallTime = deviceWallTime
    self.monotonicInstant = monotonicInstant
    self.offsetEstimates = offsetEstimates
    self.timeZoneIdentifier = timeZoneIdentifier
  }
}
