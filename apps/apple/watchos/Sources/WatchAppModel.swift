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
    authorizationSnapshot = await authorizationService.currentSnapshot()
  }

  func prepareMeasurement() async {
    guard !isRequestingAuthorization else {
      return
    }

    isRequestingAuthorization = true
    authorizationErrorCode = nil
    defer { isRequestingAuthorization = false }

    do {
      latestAuthorizationRequest = try await authorizationService.requestAuthorization()
      authorizationSnapshot = await authorizationService.currentSnapshot()
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
}
