import CoherenceAcquisition
import CoherenceCore
import Foundation
import Observation

@MainActor
@Observable
final class WatchAppModel {
  let sensorMode: AppleSensorMode
  let sensorAdapter: any SensorAdapter
  let schemaVersion = SampleBatch.currentSchemaVersion
  private let authorizationService: any MeasurementAuthorizationService
  private let sessionService: (any MeasurementSessionLifecycleService)?
  private var authorizationOperationGeneration = 0

  private(set) var authorizationSnapshot: MeasurementAuthorizationSnapshot
  private(set) var latestAuthorizationRequest: MeasurementAuthorizationRequestRecord?
  private(set) var authorizationErrorCode: String?
  private(set) var isRequestingAuthorization = false
  private(set) var sessionProjection: MeasurementSessionProjection?
  private(set) var sessionErrorCode: String?
  private(set) var isTransitioningSession = false

  init(
    sensorServices: BootstrapSensorServices,
    authorizationServices: BootstrapAuthorizationServices,
    sessionServices: BootstrapSessionServices
  ) {
    sensorMode = sensorServices.mode
    sensorAdapter = sensorServices.adapter
    authorizationService = authorizationServices.service
    authorizationSnapshot = authorizationServices.initialSnapshot
    sessionService = sessionServices.service
  }

  var sessionFixtureAvailable: Bool {
    sessionService != nil
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

  func requestMeasurementAccess() async {
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

  func startSyntheticRehearsal() async {
    guard let sessionService, !isTransitioningSession else {
      return
    }

    isTransitioningSession = true
    sessionErrorCode = nil
    defer { isTransitioningSession = false }

    do {
      if sessionProjection?.session.state != .prepared {
        let preparation = MeasurementSessionPreparation(
          participantID: UUID(
            uuidString: "00000000-0000-0000-0000-000000000602"
          )!,
          activityLabel: "Synthetic rehearsal",
          captureIntent: .synthetic
        )
        _ = try await sessionService.perform(.prepare(preparation))
      }
      let transition = try await sessionService.perform(.start)
      sessionProjection = transition.projection
    } catch {
      sessionErrorCode = Self.sessionErrorCode(for: error)
      await refreshSessionProjectionAfterFailure(using: sessionService)
    }
  }

  func pauseSyntheticRehearsal() async {
    await performSessionCommand(.pause)
  }

  func resumeSyntheticRehearsal() async {
    await performSessionCommand(.resume)
  }

  func endSyntheticRehearsal() async {
    await performSessionCommand(.end)
  }

  func saveSyntheticRehearsal() async {
    await performSessionCommand(.save)
  }

  func discardSyntheticRehearsal() async {
    await performSessionCommand(.discard)
  }

  private func performSessionCommand(_ command: MeasurementSessionCommand) async {
    guard let sessionService, !isTransitioningSession else {
      return
    }

    isTransitioningSession = true
    sessionErrorCode = nil
    defer { isTransitioningSession = false }

    do {
      let transition = try await sessionService.perform(command)
      sessionProjection = transition.projection
    } catch {
      sessionErrorCode = Self.sessionErrorCode(for: error)
      await refreshSessionProjectionAfterFailure(using: sessionService)
    }
  }

  private func refreshSessionProjectionAfterFailure(
    using sessionService: any MeasurementSessionLifecycleService
  ) async {
    do {
      sessionProjection = try await sessionService.currentProjection()
    } catch {
      sessionErrorCode = "session.replay-failed"
    }
  }

  private static func sessionErrorCode(for error: Error) -> String {
    guard let serviceError = error as? MeasurementSessionLifecycleServiceError else {
      return "session.transition-failed"
    }
    return switch serviceError {
    case .noSession:
      "session.not-prepared"
    case .activeSession:
      "session.already-active"
    case .invalidTransition:
      "session.invalid-transition"
    case .projectionFailed:
      "session.projection-failed"
    }
  }
}
