import Foundation

public enum SampleBatchValidationError: Error, Equatable, Sendable {
  case empty
  case missingContentDigest
  case mixedStreams
  case nonIncreasingSequence
}

public struct SampleBatch: Identifiable, Codable, Equatable, Sendable {
  public static let currentSchemaVersion = 1

  public let id: UUID
  public let streamID: UUID
  public let sessionID: UUID?
  public let createdAt: Date
  public let schemaVersion: Int
  public let contentDigest: String
  public let samples: [SensorSample]

  public init(
    id: UUID,
    streamID: UUID,
    sessionID: UUID? = nil,
    createdAt: Date,
    schemaVersion: Int = SampleBatch.currentSchemaVersion,
    contentDigest: String,
    samples: [SensorSample]
  ) throws {
    guard !samples.isEmpty else {
      throw SampleBatchValidationError.empty
    }
    guard !contentDigest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw SampleBatchValidationError.missingContentDigest
    }
    guard samples.allSatisfy({ $0.streamID == streamID }) else {
      throw SampleBatchValidationError.mixedStreams
    }

    let sequenceNumbers = samples.compactMap(\.sequenceNumber)
    guard zip(sequenceNumbers, sequenceNumbers.dropFirst()).allSatisfy({ $0 < $1 }) else {
      throw SampleBatchValidationError.nonIncreasingSequence
    }

    self.id = id
    self.streamID = streamID
    self.sessionID = sessionID
    self.createdAt = createdAt
    self.schemaVersion = schemaVersion
    self.contentDigest = contentDigest
    self.samples = samples
  }
}
