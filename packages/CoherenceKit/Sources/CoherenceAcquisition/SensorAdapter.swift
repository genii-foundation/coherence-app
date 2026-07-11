import CoherenceCore
import Foundation

public struct SensorAdapterContext: Sendable {
  public let session: MeasurementSession

  public init(session: MeasurementSession) {
    self.session = session
  }
}

public protocol SensorAdapter: Sendable {
  var identifier: String { get }
  var supportedKinds: Set<SensorKind> { get }

  func batches(for context: SensorAdapterContext) -> AsyncThrowingStream<SampleBatch, Error>
  func stop() async
}
