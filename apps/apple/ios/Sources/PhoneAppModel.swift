import CoherenceAcquisition
import CoherenceCore
import Foundation
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
  let sessionFixtureAvailable: Bool
  let schemaVersion = SampleBatch.currentSchemaVersion
  private let authorizationService: any MeasurementAuthorizationService
  private let diagnosticContext: AppleDiagnosticContext
  private var authorizationOperationGeneration = 0
  @ObservationIgnored private var diagnosticSnapshotCache: AppleDiagnosticSnapshot?

  private(set) var destination: PhoneDestination = .privacy
  private(set) var authorizationSnapshot: MeasurementAuthorizationSnapshot
  private(set) var latestAuthorizationRequest: MeasurementAuthorizationRequestRecord?
  private(set) var authorizationErrorCode: String?
  private(set) var isRequestingAuthorization = false

  init(
    sensorServices: BootstrapSensorServices,
    authorizationServices: BootstrapAuthorizationServices,
    diagnosticContext: AppleDiagnosticContext,
    sessionFixtureAvailable: Bool
  ) {
    sensorMode = sensorServices.mode
    sensorAdapter = sensorServices.adapter
    self.sessionFixtureAvailable = sessionFixtureAvailable
    authorizationService = authorizationServices.service
    authorizationSnapshot = authorizationServices.initialSnapshot
    self.diagnosticContext = diagnosticContext
  }

  func refreshAuthorization() async {
    guard !isRequestingAuthorization else {
      return
    }

    authorizationOperationGeneration += 1
    let generation = authorizationOperationGeneration
    let snapshot = await authorizationService.currentSnapshot()
    guard generation == authorizationOperationGeneration else {
      return
    }
    authorizationSnapshot = snapshot
    diagnosticSnapshotCache = nil
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
    diagnosticSnapshotCache = nil
    destination = .diagnostics
  }

  func requestAuthorization() async {
    guard !isRequestingAuthorization else {
      return
    }

    authorizationOperationGeneration += 1
    let generation = authorizationOperationGeneration
    isRequestingAuthorization = true
    authorizationErrorCode = nil
    defer { isRequestingAuthorization = false }

    do {
      latestAuthorizationRequest = try await authorizationService.requestAuthorization()
      let snapshot = await authorizationService.currentSnapshot()
      guard generation == authorizationOperationGeneration else {
        return
      }
      authorizationSnapshot = snapshot
      diagnosticSnapshotCache = nil
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
      let snapshot = await authorizationService.currentSnapshot()
      guard generation == authorizationOperationGeneration else {
        return
      }
      authorizationSnapshot = snapshot
      diagnosticSnapshotCache = nil
    } catch {
      authorizationErrorCode = "authorization.request-failed"
      let snapshot = await authorizationService.currentSnapshot()
      guard generation == authorizationOperationGeneration else {
        return
      }
      authorizationSnapshot = snapshot
      diagnosticSnapshotCache = nil
    }
  }

  var diagnosticSnapshot: AppleDiagnosticSnapshot {
    if let diagnosticSnapshotCache {
      return diagnosticSnapshotCache
    }

    let snapshot = AppleDiagnosticSnapshot(
      runIdentifier: diagnosticContext.runIdentifier,
      generatedAt: Date(),
      applicationVersion: diagnosticContext.applicationVersion,
      applicationBuild: diagnosticContext.applicationBuild,
      role: diagnosticContext.role,
      operatingSystemVersion: diagnosticContext.operatingSystemVersion,
      sensorMode: sensorMode,
      authorizationSnapshot: authorizationSnapshot,
      latestRequest: latestAuthorizationRequest,
      authorizationErrorCode: authorizationErrorCode
    )
    diagnosticSnapshotCache = snapshot
    return snapshot
  }

  var diagnosticJSON: String {
    (try? diagnosticSnapshot.json()) ?? "{\"diagnosticExportError\":true}"
  }
}
