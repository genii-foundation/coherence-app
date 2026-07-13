import Foundation

struct WatchAppComposition {
  let model: WatchAppModel
}

enum WatchCompositionRoot {
  @MainActor
  static func make(
    arguments: [String] = ProcessInfo.processInfo.arguments
  ) -> WatchAppComposition {
    let configuration = AppleRuntimeConfiguration(arguments: arguments)
    let sensors = BootstrapSensorServices(configuration: configuration)
    let authorization = BootstrapAuthorizationServices(
      configuration: configuration,
      plan: .watchMeasurement
    )
    let sessions = BootstrapSessionServices(configuration: configuration)
    return WatchAppComposition(
      model: WatchAppModel(
        sensorServices: sensors,
        authorizationServices: authorization,
        sessionServices: sessions
      )
    )
  }
}
