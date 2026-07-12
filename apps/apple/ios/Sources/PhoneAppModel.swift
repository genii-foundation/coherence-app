import CoherenceAcquisition
import CoherenceCore
import Observation

@MainActor
@Observable
final class PhoneAppModel {
  let sensorMode: AppleSensorMode
  let sensorAdapter: any SensorAdapter
  let schemaVersion = SampleBatch.currentSchemaVersion

  init(sensorServices: BootstrapSensorServices) {
    sensorMode = sensorServices.mode
    sensorAdapter = sensorServices.adapter
  }
}
