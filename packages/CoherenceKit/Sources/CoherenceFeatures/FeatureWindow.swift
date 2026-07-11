import CoherenceCore
import Foundation

public enum FeatureKind: Codable, Equatable, Hashable, Sendable {
  case meanHeartRate
  case heartRateSlope
  case rmssd
  case sdnn
  case sampleCoverage
  case motionIntensity
  case baselineChange
  case custom(String)
}

public struct FeatureWindow: Identifiable, Codable, Equatable, Sendable {
  public let id: UUID
  public let streamID: UUID
  public let startTime: Date
  public let endTime: Date
  public let kind: FeatureKind
  public let value: Double
  public let unit: String
  public let coverage: Double
  public let confidence: Double?
  public let algorithmVersion: String

  public init(
    id: UUID,
    streamID: UUID,
    startTime: Date,
    endTime: Date,
    kind: FeatureKind,
    value: Double,
    unit: String,
    coverage: Double,
    confidence: Double? = nil,
    algorithmVersion: String
  ) {
    self.id = id
    self.streamID = streamID
    self.startTime = startTime
    self.endTime = endTime
    self.kind = kind
    self.value = value
    self.unit = unit
    self.coverage = coverage
    self.confidence = confidence
    self.algorithmVersion = algorithmVersion
  }
}
