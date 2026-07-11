import CoherenceCore
import Foundation

public protocol LocalSignalStore: Sendable {
  func append(_ batch: SampleBatch) async throws
  func batch(id: UUID) async throws -> SampleBatch?
}
