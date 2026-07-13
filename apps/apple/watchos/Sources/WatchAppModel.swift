import CoherenceAcquisition
import CoherenceCore
import Observation

@MainActor
@Observable
final class WatchAppModel {
  let sensorMode: AppleSensorMode
  let sensorAdapter: any SensorAdapter
  let schemaVersion = SampleBatch.currentSchemaVersion
  private let authorizationService: any MeasurementAuthorizationService
  private var authorizationOperationGeneration = 0

  private(set) var authorizationSnapshot: MeasurementAuthorizationSnapshot
  private(set) var latestAuthorizationRequest: MeasurementAuthorizationRequestRecord?
  private(set) var authorizationErrorCode: String?
  private(set) var isRequestingAuthorization = false

  init(
    sensorServices: BootstrapSensorServices,
    authorizationServices: BootstrapAuthorizationServices
  ) {
    sensorMode = sensorServices.mode
    sensorAdapter = sensorServices.adapter
    authorizationService = authorizationServices.service
    authorizationSnapshot = authorizationServices.initialSnapshot
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
  }

  func prepareMeasurement() async {
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
    } catch {
      authorizationErrorCode = "authorization.request-failed"
      let snapshot = await authorizationService.currentSnapshot()
      guard generation == authorizationOperationGeneration else {
        return
      }
      authorizationSnapshot = snapshot
    }
  }
}
