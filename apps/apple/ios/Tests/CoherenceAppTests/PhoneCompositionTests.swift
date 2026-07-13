import CoherenceAcquisition
import CoherenceCore
import Foundation
import Testing

@testable import CoherenceApp

struct PhoneCompositionTests {
  @Test
  @MainActor
  func fakeArgumentSelectsSyntheticAdapter() async throws {
    let composition = PhoneCompositionRoot.make(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    )

    #expect(composition.model.sensorMode == .synthetic)
    #expect(composition.model.sensorAdapter is SyntheticSensorAdapter)

    let session = MeasurementSession(
      id: UUID(uuidString: "00000000-0000-0000-0000-000000000201")!,
      participantID: UUID(uuidString: "00000000-0000-0000-0000-000000000202")!,
      captureIntent: .synthetic,
      state: .recording
    )
    let stream = composition.model.sensorAdapter.batches(
      for: SensorAdapterContext(session: session)
    )
    var iterator = stream.makeAsyncIterator()
    let batch = try await iterator.next()

    #expect(batch?.samples.count == 1)
    #expect(batch?.samples.first?.captureIntent == .synthetic)
    #expect(batch?.samples.first?.acquisitionSource == .synthetic)
    #expect(batch?.samples.first?.provenance.metadata["synthetic"] == "true")
  }

  @Test
  @MainActor
  func defaultCompositionDoesNotReachHealthKit() {
    let composition = PhoneCompositionRoot.make(arguments: [])

    #expect(composition.model.sensorMode == .unavailable)
    #expect(composition.model.sensorAdapter is UnavailableSensorAdapter)
  }
}
