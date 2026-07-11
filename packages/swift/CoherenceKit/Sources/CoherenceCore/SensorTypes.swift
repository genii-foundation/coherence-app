import Foundation

public enum SensorKind: Codable, Equatable, Hashable, Sendable {
  case heartRate
  case heartRateVariabilitySDNN
  case rrInterval
  case restingHeartRate
  case respiratoryRate
  case sleepStage
  case stepCount
  case activeEnergy
  case motionMagnitude
  case annotation
  case custom(String)
}

public enum SensorValue: Codable, Equatable, Sendable {
  case scalar(Double)
  case category(String)
  case vector([Double])
}

public enum CaptureIntent: String, Codable, Equatable, Hashable, Sendable {
  case passive
  case explicit
  case imported
  case manual
  case synthetic
}

public enum AcquisitionSourceKind: String, Codable, Equatable, Sendable {
  case healthRepository
  case liveWearable
  case directPeripheral
  case annotation
  case synthetic
}

public enum QualityLevel: String, Codable, Equatable, Sendable {
  case unknown
  case good
  case questionable
  case invalid
}

public enum QualityFlag: String, Codable, Equatable, Hashable, Sendable {
  case clockUncertain
  case duplicate
  case gapAdjacent
  case interpolated
  case motionContaminated
  case outOfRange
  case packetLoss
  case sourceReportedPoor
}

public struct SignalQuality: Codable, Equatable, Sendable {
  public let level: QualityLevel
  public let flags: Set<QualityFlag>

  public init(level: QualityLevel = .unknown, flags: Set<QualityFlag> = []) {
    self.level = level
    self.flags = flags
  }
}
