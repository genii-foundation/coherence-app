import Foundation

enum AppleSensorMode: String, Equatable, Sendable {
  case unavailable
  case synthetic

  var displayName: String {
    switch self {
    case .unavailable:
      "Sensors arrive in Phase 1"
    case .synthetic:
      "Synthetic sensors active"
    }
  }
}

struct AppleRuntimeConfiguration: Equatable, Sendable {
  static let fakeSensorArgument = "COHERENCE_USE_FAKE_SENSORS=1"

  let sensorMode: AppleSensorMode

  init(arguments: [String]) {
    #if DEBUG
      sensorMode = arguments.contains(Self.fakeSensorArgument) ? .synthetic : .unavailable
    #else
      sensorMode = .unavailable
    #endif
  }
}
