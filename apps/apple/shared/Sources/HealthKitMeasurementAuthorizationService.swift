import CoherenceAcquisition
import Foundation
import HealthKit

actor HealthKitMeasurementAuthorizationService: MeasurementAuthorizationService {
  private struct TypeSets {
    let share: Set<HKSampleType>
    let read: Set<HKObjectType>
  }

  private let healthStore: HKHealthStore
  private let plan: AppleAuthorizationPlan
  private var latestRequestID: UUID?

  init(
    plan: AppleAuthorizationPlan,
    healthStore: HKHealthStore = HKHealthStore()
  ) {
    self.plan = plan
    self.healthStore = healthStore
  }

  static func initialSnapshot(
    plan: AppleAuthorizationPlan,
    observedAt: Date
  ) -> MeasurementAuthorizationSnapshot {
    let available = HKHealthStore.isHealthDataAvailable()
    return MeasurementAuthorizationSnapshot(
      intents: plan.intents,
      readiness: available ? .notRequested : .unavailable,
      observations: initialObservations(for: plan, available: available),
      healthDataAvailable: available,
      observedAt: observedAt,
      evidenceSource: available ? evidenceSource : .unavailable
    )
  }

  func currentSnapshot() async -> MeasurementAuthorizationSnapshot {
    let observedAt = Date()
    guard HKHealthStore.isHealthDataAvailable() else {
      return MeasurementAuthorizationSnapshot(
        intents: plan.intents,
        readiness: .unavailable,
        observations: Self.initialObservations(for: plan, available: false),
        healthDataAvailable: false,
        observedAt: observedAt,
        evidenceSource: .unavailable,
        latestRequestID: latestRequestID
      )
    }

    do {
      let typeSets = try makeTypeSets()
      let status = try await requestStatus(for: typeSets)
      let readiness: MeasurementAuthorizationReadiness =
        switch status {
        case .shouldRequest:
          .requestNeeded
        case .unnecessary:
          latestRequestID == nil ? .requestNotNeeded : .requestRecorded
        case .unknown:
          .notRequested
        @unknown default:
          .notRequested
        }

      return MeasurementAuthorizationSnapshot(
        intents: plan.intents,
        readiness: readiness,
        observations: observations(for: plan),
        healthDataAvailable: true,
        observedAt: observedAt,
        evidenceSource: Self.evidenceSource,
        latestRequestID: latestRequestID
      )
    } catch {
      let errorCode = Self.inspectionErrorCode(for: error)
      return MeasurementAuthorizationSnapshot(
        intents: plan.intents,
        readiness: .notRequested,
        observations: observations(for: plan),
        healthDataAvailable: true,
        observedAt: observedAt,
        evidenceSource: Self.evidenceSource,
        latestRequestID: latestRequestID,
        inspectionErrorCode: errorCode
      )
    }
  }

  func requestAuthorization() async throws -> MeasurementAuthorizationRequestRecord {
    guard HKHealthStore.isHealthDataAvailable() else {
      throw MeasurementAuthorizationServiceError.unavailable
    }

    let typeSets = try makeTypeSets()
    try await requestAccess(for: typeSets)

    let record = MeasurementAuthorizationRequestRecord(
      id: UUID(),
      intents: plan.intents,
      requestedAt: Date(),
      result: .completed
    )
    latestRequestID = record.id
    return record
  }

  private static var evidenceSource: MeasurementAuthorizationEvidenceSource {
    #if targetEnvironment(simulator)
      .simulator
    #else
      .physicalDevice
    #endif
  }

  static func inspectionErrorCode(for error: Error) -> String {
    if let serviceError = error as? MeasurementAuthorizationServiceError {
      return switch serviceError {
      case .unavailable:
        "authorization.unavailable"
      case .needsCompanion:
        "authorization.needs-companion"
      case .requestFailed(let code):
        code
      }
    }

    let platformError = error as NSError
    let domainCategory =
      switch platformError.domain {
      case HKErrorDomain:
        "healthkit"
      case NSCocoaErrorDomain:
        "cocoa"
      default:
        "platform"
      }
    return "healthkit.authorization-status.\(domainCategory).\(platformError.code)"
  }

  private static func initialObservations(
    for plan: AppleAuthorizationPlan,
    available: Bool
  ) -> [MeasurementAuthorizationIntent: MeasurementAuthorizationObservation] {
    Dictionary(
      uniqueKeysWithValues: plan.intents.map { intent in
        let observation: MeasurementAuthorizationObservation
        if !available {
          observation = .notApplicable
        } else {
          observation = intent == .workoutRecording ? .notDetermined : .notInspectable
        }
        return (intent, observation)
      })
  }

  private func observations(
    for plan: AppleAuthorizationPlan
  ) -> [MeasurementAuthorizationIntent: MeasurementAuthorizationObservation] {
    Dictionary(
      uniqueKeysWithValues: plan.intents.map { intent in
        let observation: MeasurementAuthorizationObservation
        switch intent {
        case .historicalHeartRate, .historicalHeartRateVariability, .liveHeartRate:
          observation = .notInspectable
        case .workoutRecording:
          switch healthStore.authorizationStatus(for: HKObjectType.workoutType()) {
          case .notDetermined:
            observation = .notDetermined
          case .sharingDenied:
            observation = .denied
          case .sharingAuthorized:
            observation = .authorized
          @unknown default:
            observation = .notDetermined
          }
        }
        return (intent, observation)
      })
  }

  private func makeTypeSets() throws -> TypeSets {
    guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else {
      throw MeasurementAuthorizationServiceError.requestFailed(
        code: "healthkit.heart-rate-type-unavailable"
      )
    }

    switch plan {
    case .phoneHistory:
      return TypeSets(share: [], read: [heartRate])
    case .watchMeasurement:
      return TypeSets(share: [HKObjectType.workoutType()], read: [heartRate])
    }
  }

  private func requestStatus(for typeSets: TypeSets) async throws -> HKAuthorizationRequestStatus {
    try await withCheckedThrowingContinuation { continuation in
      healthStore.getRequestStatusForAuthorization(
        toShare: typeSets.share,
        read: typeSets.read
      ) { status, error in
        if let error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: status)
        }
      }
    }
  }

  private func requestAccess(for typeSets: TypeSets) async throws {
    try await withCheckedThrowingContinuation {
      (continuation: CheckedContinuation<Void, Error>) in
      healthStore.requestAuthorization(
        toShare: typeSets.share,
        read: typeSets.read
      ) { success, error in
        if let error {
          continuation.resume(throwing: error)
        } else if !success {
          continuation.resume(
            throwing: MeasurementAuthorizationServiceError.requestFailed(
              code: "healthkit.request-not-completed"
            )
          )
        } else {
          continuation.resume(returning: ())
        }
      }
    }
  }
}
