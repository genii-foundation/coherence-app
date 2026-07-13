import CoherenceAcquisition
import CoherenceCore
import Foundation

struct BootstrapSensorServices: Sendable {
  let mode: AppleSensorMode
  let adapter: any SensorAdapter

  init(configuration: AppleRuntimeConfiguration) {
    mode = configuration.sensorMode
    switch configuration.sensorMode {
    case .synthetic:
      adapter = SyntheticSensorAdapter()
    case .unavailable:
      adapter = UnavailableSensorAdapter()
    }
  }
}

struct UnavailableSensorAdapter: SensorAdapter {
  let identifier = "org.providencecollective.coherence.unavailable"
  let supportedKinds: Set<SensorKind> = []

  func batches(
    for context: SensorAdapterContext
  ) -> AsyncThrowingStream<SampleBatch, Error> {
    AsyncThrowingStream { continuation in
      continuation.finish()
    }
  }

  func stop() async {}
}

struct SyntheticSensorAdapter: SensorAdapter {
  let identifier = "org.providencecollective.coherence.synthetic"
  let supportedKinds: Set<SensorKind> = [.heartRate]

  func batches(
    for context: SensorAdapterContext
  ) -> AsyncThrowingStream<SampleBatch, Error> {
    AsyncThrowingStream { continuation in
      do {
        continuation.yield(try makeBatch(sessionID: context.session.id))
        continuation.finish()
      } catch {
        continuation.finish(throwing: error)
      }
    }
  }

  func stop() async {}

  private func makeBatch(sessionID: UUID) throws -> SampleBatch {
    let timestamp = Date(timeIntervalSince1970: 1_750_000_000)
    let streamID = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
    let sample = SensorSample(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!,
      streamID: streamID,
      kind: .heartRate,
      value: .scalar(64),
      unit: "count/min",
      sourceStartTime: timestamp,
      observedAt: ClockContext(
        deviceWallTime: timestamp,
        timeZoneIdentifier: "UTC"
      ),
      captureIntent: .synthetic,
      acquisitionSource: .synthetic,
      sequenceNumber: 1,
      quality: SignalQuality(level: .good),
      provenance: SampleProvenance(
        source: SourceIdentity(
          namespace: "org.providencecollective.coherence.fixture",
          identifier: "phase-0b-heart-rate"
        ),
        metadata: ["synthetic": "true"]
      )
    )

    return try SampleBatch(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000103")!,
      streamID: streamID,
      sessionID: sessionID,
      createdAt: timestamp,
      contentDigest: "sha256:phase-0b-synthetic-batch",
      samples: [sample]
    )
  }
}
