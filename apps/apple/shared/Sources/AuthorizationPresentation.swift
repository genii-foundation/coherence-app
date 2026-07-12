import CoherenceAcquisition

extension MeasurementAuthorizationReadiness {
  var displayName: String {
    switch self {
    case .notRequested:
      "Not checked yet"
    case .requestNeeded:
      "Access request needed"
    case .requestRecorded:
      "Access request recorded"
    case .unavailable:
      "Health data unavailable"
    case .needsCompanion:
      "Continue on the companion device"
    }
  }

  var explanation: String {
    switch self {
    case .notRequested:
      "Coherence has not inspected whether an access request is needed."
    case .requestNeeded:
      "You can choose whether to continue to Apple's health access sheet."
    case .requestRecorded:
      "The request completed. Apple keeps individual health read choices private from apps."
    case .unavailable:
      "This environment cannot provide Apple health data."
    case .needsCompanion:
      "Continue this step on the paired device where collection will occur."
    }
  }

  var canRequestAccess: Bool {
    self == .notRequested || self == .requestNeeded
  }
}

extension MeasurementAuthorizationObservation {
  var displayName: String {
    switch self {
    case .notInspectable:
      "Read choice remains private"
    case .notDetermined:
      "Sharing not decided"
    case .denied:
      "Sharing not allowed"
    case .authorized:
      "Sharing allowed"
    case .notApplicable:
      "Not available here"
    }
  }
}
