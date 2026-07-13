import CoherenceAcquisition
import Foundation

enum AppleAuthorizationPlan: Equatable, Sendable {
  case phoneHistory
  case watchMeasurement

  var intents: Set<MeasurementAuthorizationIntent> {
    switch self {
    case .phoneHistory:
      [.historicalHeartRate]
    case .watchMeasurement:
      [.liveHeartRate, .workoutRecording]
    }
  }
}

extension MeasurementAuthorizationIntent {
  var displayName: String {
    switch self {
    case .historicalHeartRate:
      "Heart rate history"
    case .historicalHeartRateVariability:
      "Heart rate variability history"
    case .liveHeartRate:
      "Live heart rate during an explicit session"
    case .workoutRecording:
      "Save the explicit measurement as a workout"
    }
  }

  var purposeDescription: String {
    switch self {
    case .historicalHeartRate:
      "Build a private personal baseline and compare explicit sessions with your own history."
    case .historicalHeartRateVariability:
      "Add a separately labeled variability signal when the historical importer is implemented."
    case .liveHeartRate:
      "Observe heart rate only while you deliberately run a measurement session."
    case .workoutRecording:
      "Allow the Watch to run an explicit measurement session using Apple workout infrastructure."
    }
  }
}

struct BootstrapAuthorizationServices: Sendable {
  let service: any MeasurementAuthorizationService
  let initialSnapshot: MeasurementAuthorizationSnapshot

  init(
    service: any MeasurementAuthorizationService,
    initialSnapshot: MeasurementAuthorizationSnapshot
  ) {
    self.service = service
    self.initialSnapshot = initialSnapshot
  }

  init(
    configuration: AppleRuntimeConfiguration,
    plan: AppleAuthorizationPlan
  ) {
    #if DEBUG
      if let fixture = configuration.authorizationFixture {
        let snapshot = Self.fixtureSnapshot(
          plan: plan,
          fixture: fixture,
          observedAt: configuration.observedAt
        )
        service = FixtureMeasurementAuthorizationService(
          snapshot: snapshot,
          requestID: UUID(uuidString: "00000000-0000-0000-0000-000000000402")!,
          requestedAt: configuration.observedAt,
          failsRequest: fixture == .requestFailure
        )
        initialSnapshot = snapshot
        return
      }
    #endif

    service = HealthKitMeasurementAuthorizationService(plan: plan)
    initialSnapshot = HealthKitMeasurementAuthorizationService.initialSnapshot(
      plan: plan,
      observedAt: configuration.observedAt
    )
  }

  private static func fixtureSnapshot(
    plan: AppleAuthorizationPlan,
    fixture: AppleAuthorizationFixture,
    observedAt: Date
  ) -> MeasurementAuthorizationSnapshot {
    let readiness: MeasurementAuthorizationReadiness =
      switch fixture {
      case .needsRequest, .requestFailure:
        .requestNeeded
      case .requestRecorded, .writeDenied:
        .requestRecorded
      case .unavailable:
        .unavailable
      case .needsCompanion:
        .needsCompanion
      }

    let observations = Dictionary(
      uniqueKeysWithValues: plan.intents.map { intent in
        let observation: MeasurementAuthorizationObservation
        switch intent {
        case .historicalHeartRate, .historicalHeartRateVariability, .liveHeartRate:
          observation = .notInspectable
        case .workoutRecording:
          observation =
            switch fixture {
            case .requestRecorded:
              .authorized
            case .writeDenied:
              .denied
            default:
              .notDetermined
            }
        }
        return (intent, observation)
      })

    return MeasurementAuthorizationSnapshot(
      intents: plan.intents,
      readiness: readiness,
      observations: observations,
      healthDataAvailable: fixture != .unavailable,
      observedAt: observedAt,
      evidenceSource: .fixture,
      latestRequestID: readiness == .requestRecorded
        ? UUID(uuidString: "00000000-0000-0000-0000-000000000402")!
        : nil
    )
  }
}

#if DEBUG
  actor FixtureMeasurementAuthorizationService: MeasurementAuthorizationService {
    private var snapshot: MeasurementAuthorizationSnapshot
    private let requestID: UUID
    private let requestedAt: Date
    private let failsRequest: Bool
    private(set) var requestCount = 0

    init(
      snapshot: MeasurementAuthorizationSnapshot,
      requestID: UUID,
      requestedAt: Date,
      failsRequest: Bool
    ) {
      self.snapshot = snapshot
      self.requestID = requestID
      self.requestedAt = requestedAt
      self.failsRequest = failsRequest
    }

    func currentSnapshot() -> MeasurementAuthorizationSnapshot {
      snapshot
    }

    func requestAuthorization() throws -> MeasurementAuthorizationRequestRecord {
      requestCount += 1

      switch snapshot.readiness {
      case .unavailable:
        throw MeasurementAuthorizationServiceError.unavailable
      case .needsCompanion:
        throw MeasurementAuthorizationServiceError.needsCompanion
      case .notRequested, .requestNeeded, .requestNotNeeded, .requestRecorded:
        break
      }

      if failsRequest {
        throw MeasurementAuthorizationServiceError.requestFailed(code: "fixture.request-failed")
      }

      let record = MeasurementAuthorizationRequestRecord(
        id: requestID,
        intents: snapshot.intents,
        requestedAt: requestedAt,
        result: .completed
      )
      snapshot = MeasurementAuthorizationSnapshot(
        intents: snapshot.intents,
        readiness: .requestRecorded,
        observations: snapshot.observations.mapValues { observation in
          observation == .notDetermined ? .authorized : observation
        },
        healthDataAvailable: snapshot.healthDataAvailable,
        observedAt: requestedAt,
        evidenceSource: .fixture,
        latestRequestID: requestID
      )
      return record
    }
  }
#endif
