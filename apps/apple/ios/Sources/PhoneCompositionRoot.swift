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
    let authorization = BootstrapAuthorizationServices(
      configuration: configuration,
      plan: .phoneHistory
    )
    let diagnostics = AppleDiagnosticContext.current(
      configuration: configuration,
      role: .phone
    )
    return PhoneAppComposition(
      model: PhoneAppModel(
        sensorServices: sensors,
        authorizationServices: authorization,
        diagnosticContext: diagnostics,
        sessionFixtureAvailable: configuration.sessionFixture == .interactive
      )
    )
  }
}
