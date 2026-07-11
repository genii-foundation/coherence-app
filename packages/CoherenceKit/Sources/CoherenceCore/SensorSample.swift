import Foundation

public struct SensorSample: Identifiable, Codable, Equatable, Sendable {
  public let id: UUID
  public let streamID: UUID
  public let kind: SensorKind
  public let value: SensorValue
  public let unit: String
  public let sourceStartTime: Date
  public let sourceEndTime: Date?
  public let observedAt: ClockContext
  public let samplingMode: SamplingMode
  public let sequenceNumber: UInt64?
  public let nominalSamplingRateHertz: Double?
  public let quality: SignalQuality
  public let provenance: SampleProvenance

  public init(
    id: UUID,
    streamID: UUID,
    kind: SensorKind,
    value: SensorValue,
    unit: String,
    sourceStartTime: Date,
    sourceEndTime: Date? = nil,
    observedAt: ClockContext,
    samplingMode: SamplingMode,
    sequenceNumber: UInt64? = nil,
    nominalSamplingRateHertz: Double? = nil,
    quality: SignalQuality = .init(),
    provenance: SampleProvenance = .init()
  ) {
    self.id = id
    self.streamID = streamID
    self.kind = kind
    self.value = value
    self.unit = unit
    self.sourceStartTime = sourceStartTime
    self.sourceEndTime = sourceEndTime
    self.observedAt = observedAt
    self.samplingMode = samplingMode
    self.sequenceNumber = sequenceNumber
    self.nominalSamplingRateHertz = nominalSamplingRateHertz
    self.quality = quality
    self.provenance = provenance
  }
}
