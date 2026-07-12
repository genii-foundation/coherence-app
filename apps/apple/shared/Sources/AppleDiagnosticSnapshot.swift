import CoherenceAcquisition
import Foundation

enum AppleApplicationRole: String, Codable, Equatable, Sendable {
  case phone
  case watch

  var platformName: String {
    switch self {
    case .phone:
      "iOS"
    case .watch:
      "watchOS"
    }
  }
}

struct AppleAuthorizationDiagnostic: Codable, Equatable, Sendable {
  let intent: String
  let observation: String
}

struct AppleDiagnosticSnapshot: Codable, Equatable, Sendable {
  static let currentSchemaVersion = 1

  let schemaVersion: Int
  let runIdentifier: UUID
  let generatedAt: Date
  let applicationVersion: String
  let applicationBuild: String
  let platform: String
  let deviceClass: String
  let operatingSystemVersion: String
  let sensorMode: String
  let authorizationReadiness: String
  let authorizationObservedAt: Date
  let healthDataAvailable: Bool
  let evidenceSource: String
  let requestedAccess: [AppleAuthorizationDiagnostic]
  let latestAuthorizationRequestIdentifier: UUID?
  let latestAuthorizationRequestResult: String?
  let authorizationInspectionErrorCode: String?
  let authorizationErrorCode: String?
  let biometricValuesIncluded: Bool
  let participantIdentityIncluded: Bool
  let persistentDeviceIdentifierIncluded: Bool

  init(
    runIdentifier: UUID,
    generatedAt: Date,
    applicationVersion: String,
    applicationBuild: String,
    role: AppleApplicationRole,
    operatingSystemVersion: String,
    sensorMode: AppleSensorMode,
    authorizationSnapshot: MeasurementAuthorizationSnapshot,
    latestRequest: MeasurementAuthorizationRequestRecord?,
    authorizationErrorCode: String?
  ) {
    schemaVersion = Self.currentSchemaVersion
    self.runIdentifier = runIdentifier
    self.generatedAt = generatedAt
    self.applicationVersion = applicationVersion
    self.applicationBuild = applicationBuild
    platform = role.platformName
    deviceClass = role.rawValue
    self.operatingSystemVersion = operatingSystemVersion
    self.sensorMode = sensorMode.rawValue
    authorizationReadiness = authorizationSnapshot.readiness.rawValue
    authorizationObservedAt = authorizationSnapshot.observedAt
    healthDataAvailable = authorizationSnapshot.healthDataAvailable
    evidenceSource = authorizationSnapshot.evidenceSource.rawValue
    requestedAccess = authorizationSnapshot.intents
      .map { intent in
        AppleAuthorizationDiagnostic(
          intent: intent.rawValue,
          observation: authorizationSnapshot.observations[intent, default: .notApplicable].rawValue
        )
      }
      .sorted { $0.intent < $1.intent }
    latestAuthorizationRequestIdentifier =
      latestRequest?.id
      ?? authorizationSnapshot.latestRequestID
    latestAuthorizationRequestResult = latestRequest?.result.rawValue
    authorizationInspectionErrorCode = authorizationSnapshot.inspectionErrorCode
    self.authorizationErrorCode = authorizationErrorCode
    biometricValuesIncluded = false
    participantIdentityIncluded = false
    persistentDeviceIdentifierIncluded = false
  }

  func json() throws -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try encoder.encode(self)
    guard let value = String(data: data, encoding: .utf8) else {
      throw CocoaError(.fileWriteInapplicableStringEncoding)
    }
    return value
  }
}

struct AppleDiagnosticContext: Equatable, Sendable {
  let runIdentifier: UUID
  let applicationVersion: String
  let applicationBuild: String
  let role: AppleApplicationRole
  let operatingSystemVersion: String

  static func current(
    configuration: AppleRuntimeConfiguration,
    role: AppleApplicationRole,
    bundle: Bundle = .main,
    processInfo: ProcessInfo = .processInfo
  ) -> AppleDiagnosticContext {
    AppleDiagnosticContext(
      runIdentifier: configuration.diagnosticRunIdentifier,
      applicationVersion: bundle.object(
        forInfoDictionaryKey: "CFBundleShortVersionString"
      ) as? String ?? "unknown",
      applicationBuild: bundle.object(
        forInfoDictionaryKey: "CFBundleVersion"
      ) as? String ?? "unknown",
      role: role,
      operatingSystemVersion: processInfo.operatingSystemVersionString
    )
  }
}
