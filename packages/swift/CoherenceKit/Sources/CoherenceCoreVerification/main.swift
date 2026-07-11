import CoherenceCore
import Foundation

enum VerificationError: Error {
  case roundTripChangedBatch
  case mixedStreamWasAccepted
  case wrongValidationError
}

@main
struct CoherenceCoreVerification {
  static func main() throws {
    try verifyRoundTrip()
    try verifyMixedStreamRejection()
    print("CoherenceCore contracts verified.")
  }

  private static func verifyRoundTrip() throws {
    let streamID = UUID()
    let timestamp = Date(timeIntervalSince1970: 1_750_000_000)
    let sample = SensorSample(
      id: UUID(),
      streamID: streamID,
      kind: .heartRate,
      value: .scalar(64),
      unit: "count/min",
      sourceStartTime: timestamp,
      observedAt: ClockContext(
        deviceWallTime: timestamp,
        monotonicInstant: MonotonicInstant(
          clockIdentifier: "test-clock",
          ticks: 42,
          ticksPerSecond: 1_000
        ),
        offsetEstimates: [
          ClockOffsetEstimate(
            referenceClockIdentifier: "phone-clock",
            offsetSeconds: 0.015,
            roundTripSeconds: 0.006,
            uncertaintySeconds: 0.004,
            measuredAt: timestamp
          )
        ],
        timeZoneIdentifier: "America/Los_Angeles"
      ),
      captureIntent: .explicit,
      acquisitionSource: .liveWearable,
      sequenceNumber: 1,
      quality: SignalQuality(level: .good),
      provenance: SampleProvenance(
        source: SourceIdentity(
          namespace: "apple.bundle",
          identifier: "com.apple.health"
        ),
        deviceManufacturer: "Apple Inc.",
        deviceModel: "Watch",
        originalSampleIdentifier: UUID().uuidString
      )
    )
    let batch = try SampleBatch(
      id: UUID(),
      streamID: streamID,
      createdAt: timestamp,
      contentDigest: "sha256:test-round-trip",
      samples: [sample]
    )

    let encoded = try JSONEncoder().encode(batch)
    let decoded = try JSONDecoder().decode(SampleBatch.self, from: encoded)

    guard decoded == batch else {
      throw VerificationError.roundTripChangedBatch
    }
  }

  private static func verifyMixedStreamRejection() throws {
    let timestamp = Date(timeIntervalSince1970: 1_750_000_000)
    let sample = SensorSample(
      id: UUID(),
      streamID: UUID(),
      kind: .heartRate,
      value: .scalar(64),
      unit: "count/min",
      sourceStartTime: timestamp,
      observedAt: ClockContext(
        deviceWallTime: timestamp,
        timeZoneIdentifier: "UTC"
      ),
      captureIntent: .explicit,
      acquisitionSource: .liveWearable
    )

    do {
      _ = try SampleBatch(
        id: UUID(),
        streamID: UUID(),
        createdAt: timestamp,
        contentDigest: "sha256:test-mixed-stream",
        samples: [sample]
      )
      throw VerificationError.mixedStreamWasAccepted
    } catch SampleBatchValidationError.mixedStreams {
      return
    } catch {
      throw VerificationError.wrongValidationError
    }
  }
}
