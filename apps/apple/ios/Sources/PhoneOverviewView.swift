import CoherenceAcquisition
import SwiftUI

struct PhoneOverviewView: View {
  let sensorMode: AppleSensorMode
  let sessionFixtureAvailable: Bool
  let schemaVersion: Int
  let authorizationSnapshot: MeasurementAuthorizationSnapshot
  let onReviewAccess: () -> Void
  let onShowDiagnostics: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Capability readiness")
            .font(.largeTitle.bold())
            .accessibilityIdentifier("coherence.phone.overview.title")
          Text("This screen reports setup state. It is not a physiological dashboard.")
            .foregroundStyle(.secondary)
        }

        ReadinessCard(
          icon: "heart.text.square",
          title: authorizationSnapshot.readiness.displayName,
          detail: authorizationSnapshot.readiness.explanation,
          identifier: "coherence.phone.readiness"
        )

        ReadinessCard(
          icon: "waveform.path.ecg",
          title: sensorMode.displayName,
          detail: sensorMode == .synthetic
            ? "Every generated sample is labeled as synthetic provenance."
            : "Live collection remains unavailable until the physical capability spike.",
          identifier: "coherence.phone.sensor-mode"
        )

        if sessionFixtureAvailable {
          ReadinessCard(
            icon: "applewatch",
            title: "Watch session rehearsal",
            detail:
              "Start the synthetic lifecycle in the Watch app. This phone does not receive Watch session state yet.",
            identifier: "coherence.phone.session-rehearsal.title",
            detailIdentifier: "coherence.phone.session-rehearsal.detail"
          )
        }

        HStack(spacing: 12) {
          Button("Review access", action: onReviewAccess)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)

          Button("Diagnostics", action: onShowDiagnostics)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("coherence.phone.diagnostics.open")
        }

        Text("Schema version \(schemaVersion)")
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("coherence.phone.schema-version")
      }
      .padding(24)
    }
  }
}

private struct ReadinessCard: View {
  let icon: String
  let title: String
  let detail: String
  let identifier: String
  var detailIdentifier: String? = nil

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(.green)
        .frame(width: 30)

      VStack(alignment: .leading, spacing: 5) {
        Text(title)
          .font(.headline)
          .accessibilityIdentifier(identifier)
        Text(detail)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier(detailIdentifier ?? "\(identifier).detail")
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
  }
}
