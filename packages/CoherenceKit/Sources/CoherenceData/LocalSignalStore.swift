import CoherenceCore
import Foundation

public protocol LocalSignalStore: Sendable {
  func append(_ batch: SampleBatch) async throws
  func batch(id: UUID) async throws -> SampleBatch?
  func pendingBatches(limit: Int) async throws -> [SampleBatch]
  func markUploaded(batchID: UUID, at date: Date) async throws
}
