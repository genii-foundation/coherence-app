import SwiftUI

struct WatchRootView: View {
  let model: WatchAppModel

  var body: some View {
    ScrollView {
      VStack(spacing: 10) {
        Image(systemName: "waveform.path.ecg")
          .font(.title2)
          .foregroundStyle(.green)

        Text("Explicit measurement")
          .font(.headline)
          .multilineTextAlignment(.center)
          .accessibilityIdentifier("coherence.watch.authorization.title")

        Text(
          "Preparing a session may ask for live heart rate access and permission to save a workout. Nothing starts automatically."
        )
        .font(.caption2)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

        Divider()

        Text(model.authorizationSnapshot.readiness.displayName)
          .font(.caption.weight(.semibold))
          .multilineTextAlignment(.center)
          .accessibilityIdentifier("coherence.watch.authorization.status")

        Text(model.authorizationSnapshot.readiness.explanation)
          .font(.caption2)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)

        if let inspectionErrorCode = model.authorizationSnapshot.inspectionErrorCode {
          Text("Inspection unavailable: \(inspectionErrorCode)")
            .font(.caption2)
            .foregroundStyle(.orange)
            .multilineTextAlignment(.center)
            .accessibilityIdentifier("coherence.watch.authorization.inspection-error")
        }

        if let workoutObservation = model.authorizationSnapshot.observations[.workoutRecording] {
          Text("Workout sharing: \(workoutObservation.displayName)")
            .font(.caption2.weight(.semibold))
            .multilineTextAlignment(.center)
            .accessibilityIdentifier("coherence.watch.authorization.workout")
        }

        if model.authorizationSnapshot.readiness.canRequestAccess {
          Button {
            Task { await model.prepareMeasurement() }
          } label: {
            if model.isRequestingAuthorization {
              ProgressView()
            } else {
              Text("Prepare measurement")
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(model.isRequestingAuthorization)
          .accessibilityIdentifier("coherence.watch.authorization.request")
        }

        if let errorCode = model.authorizationErrorCode {
          Text("Request failed: \(errorCode)")
            .font(.caption2)
            .foregroundStyle(.red)
            .multilineTextAlignment(.center)
            .accessibilityIdentifier("coherence.watch.authorization.error")
        }

        Text(model.sensorMode.displayName)
          .font(.caption2)
          .foregroundStyle(model.sensorMode == .synthetic ? .orange : .secondary)
          .multilineTextAlignment(.center)
          .accessibilityIdentifier("coherence.watch.sensor-mode")

        Text("Schema \(model.schemaVersion)")
          .font(.caption2)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("coherence.watch.schema-version")
      }
      .padding(.horizontal, 4)
    }
    .task {
      await model.refreshAuthorization()
    }
  }
}

#Preview {
  WatchRootView(
    model: WatchCompositionRoot.make(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    ).model
  )
}
