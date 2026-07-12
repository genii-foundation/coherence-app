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

enum AppleAuthorizationFixture: String, Equatable, Sendable {
  case needsRequest = "needs-request"
  case requestRecorded = "request-recorded"
  case writeDenied = "write-denied"
  case unavailable
  case needsCompanion = "needs-companion"
  case requestFailure = "request-failure"
}

struct AppleRuntimeConfiguration: Equatable, Sendable {
  static let fakeSensorArgument = "COHERENCE_USE_FAKE_SENSORS=1"
  static let authorizationFixtureArgumentPrefix = "COHERENCE_AUTHORIZATION_FIXTURE="
  static let fixtureRunIdentifier = UUID(
    uuidString: "00000000-0000-0000-0000-000000000401"
  )!
  static let fixtureTimestamp = Date(timeIntervalSince1970: 1_750_000_100)

  let sensorMode: AppleSensorMode
  let authorizationFixture: AppleAuthorizationFixture?
  let diagnosticRunIdentifier: UUID
  let observedAt: Date

  init(arguments: [String]) {
    #if DEBUG
      sensorMode = arguments.contains(Self.fakeSensorArgument) ? .synthetic : .unavailable
      authorizationFixture =
        arguments
        .first(where: { $0.hasPrefix(Self.authorizationFixtureArgumentPrefix) })
        .flatMap { argument in
          AppleAuthorizationFixture(
            rawValue: String(argument.dropFirst(Self.authorizationFixtureArgumentPrefix.count))
          )
        } ?? (sensorMode == .synthetic ? .needsRequest : nil)
    #else
      sensorMode = .unavailable
      authorizationFixture = nil
    #endif

    if authorizationFixture == nil {
      diagnosticRunIdentifier = UUID()
      observedAt = Date()
    } else {
      diagnosticRunIdentifier = Self.fixtureRunIdentifier
      observedAt = Self.fixtureTimestamp
    }
  }
}
