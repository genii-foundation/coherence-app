import CoherenceCore
import Foundation

public struct DeliveryDestination: Codable, Equatable, Hashable, Sendable {
  public let namespace: String
  public let identifier: String

  public init(namespace: String, identifier: String) {
    self.namespace = namespace
    self.identifier = identifier
  }
}

public protocol BatchDeliveryOutbox: Sendable {
  func pendingBatches(
    for destination: DeliveryDestination,
    limit: Int
  ) async throws -> [SampleBatch]

  func recordAcknowledgement(
    batchID: UUID,
    from destination: DeliveryDestination,
    at date: Date
  ) async throws
}
