import CoherenceAcquisition
import CoherenceCore
import Observation

enum PhoneDestination: Equatable, Sendable {
  case privacy
  case permissions
  case overview
  case diagnostics
}

@MainActor
@Observable
final class PhoneAppModel {
  let sensorMode: AppleSensorMode
  let sensorAdapter: any SensorAdapter
  let schemaVersion = SampleBatch.currentSchemaVersion
  private let authorizationService: any MeasurementAuthorizationService
  private let diagnosticContext: AppleDiagnosticContext

  private(set) var destination: PhoneDestination = .privacy
  private(set) var authorizationSnapshot: MeasurementAuthorizationSnapshot
  private(set) var latestAuthorizationRequest: MeasurementAuthorizationRequestRecord?
  private(set) var authorizationErrorCode: String?
  private(set) var isRequestingAuthorization = false

  init(
    sensorServices: BootstrapSensorServices,
    authorizationServices: BootstrapAuthorizationServices,
    diagnosticContext: AppleDiagnosticContext
  ) {
    sensorMode = sensorServices.mode
    sensorAdapter = sensorServices.adapter
    authorizationService = authorizationServices.service
    authorizationSnapshot = authorizationServices.initialSnapshot
    self.diagnosticContext = diagnosticContext
  }

  func refreshAuthorization() async {
    authorizationSnapshot = await authorizationService.currentSnapshot()
  }

  func continueFromPrivacy() {
    destination = .permissions
  }

  func showPrivacy() {
    destination = .privacy
  }

  func showPermissions() {
    destination = .permissions
  }

  func showOverview() {
    destination = .overview
  }

  func showDiagnostics() {
    destination = .diagnostics
  }

  func requestAuthorization() async {
    guard !isRequestingAuthorization else {
      return
    }

    isRequestingAuthorization = true
    authorizationErrorCode = nil
    defer { isRequestingAuthorization = false }

    do {
      latestAuthorizationRequest = try await authorizationService.requestAuthorization()
      authorizationSnapshot = await authorizationService.currentSnapshot()
      destination = .overview
    } catch let error as MeasurementAuthorizationServiceError {
      authorizationErrorCode =
        switch error {
        case .unavailable:
          "authorization.unavailable"
        case .needsCompanion:
          "authorization.needs-companion"
        case .requestFailed(let code):
          code
        }
      authorizationSnapshot = await authorizationService.currentSnapshot()
    } catch {
      authorizationErrorCode = "authorization.request-failed"
      authorizationSnapshot = await authorizationService.currentSnapshot()
    }
  }

  var diagnosticSnapshot: AppleDiagnosticSnapshot {
    AppleDiagnosticSnapshot(
      runIdentifier: diagnosticContext.runIdentifier,
      generatedAt: diagnosticContext.generatedAt,
      applicationVersion: diagnosticContext.applicationVersion,
      applicationBuild: diagnosticContext.applicationBuild,
      role: diagnosticContext.role,
      operatingSystemVersion: diagnosticContext.operatingSystemVersion,
      sensorMode: sensorMode,
      authorizationSnapshot: authorizationSnapshot,
      latestRequest: latestAuthorizationRequest,
      authorizationErrorCode: authorizationErrorCode
    )
  }

  var diagnosticJSON: String {
    (try? diagnosticSnapshot.json()) ?? "{\"diagnosticExportError\":true}"
  }
}
