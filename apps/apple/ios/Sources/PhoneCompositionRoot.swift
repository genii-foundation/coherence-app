import Foundation

struct PhoneAppComposition {
  let model: PhoneAppModel
}

enum PhoneCompositionRoot {
  @MainActor
  static func make(
    arguments: [String] = ProcessInfo.processInfo.arguments
  ) -> PhoneAppComposition {
    let configuration = AppleRuntimeConfiguration(arguments: arguments)
    let sensors = BootstrapSensorServices(configuration: configuration)
    return PhoneAppComposition(model: PhoneAppModel(sensorServices: sensors))
  }
}
