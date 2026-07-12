import CoherenceAcquisition
import SwiftUI

struct PhonePermissionsView: View {
  let snapshot: MeasurementAuthorizationSnapshot
  let errorCode: String?
  let isRequesting: Bool
  let onBack: () -> Void
  let onRequest: () -> Void
  let onContinue: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        Button("Back", systemImage: "chevron.left", action: onBack)
          .buttonStyle(.plain)

        VStack(alignment: .leading, spacing: 8) {
          Text("Apple Health access")
            .font(.largeTitle.bold())
            .accessibilityIdentifier("coherence.phone.permissions.title")
          Text("Review the exact request before deciding whether to continue.")
            .foregroundStyle(.secondary)
        }

        ForEach(snapshot.intents.sorted { $0.rawValue < $1.rawValue }, id: \.self) { intent in
          VStack(alignment: .leading, spacing: 6) {
            Text(intent.displayName)
              .font(.headline)
            Text(intent.purposeDescription)
              .font(.subheadline)
              .foregroundStyle(.secondary)
            Text(snapshot.observations[intent, default: .notApplicable].displayName)
              .font(.caption.weight(.semibold))
              .foregroundStyle(.green)
          }
          .padding(16)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }

        VStack(alignment: .leading, spacing: 6) {
          Text(snapshot.readiness.displayName)
            .font(.headline)
            .accessibilityIdentifier("coherence.phone.permissions.status")
          Text(snapshot.readiness.explanation)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        if let inspectionErrorCode = snapshot.inspectionErrorCode {
          Text(
            "Coherence could not inspect whether Apple needs a new request. Diagnostic code: \(inspectionErrorCode)"
          )
          .font(.footnote)
          .foregroundStyle(.orange)
          .accessibilityIdentifier("coherence.phone.permissions.inspection-error")
        }

        if let errorCode {
          Text("The access request could not complete. Diagnostic code: \(errorCode)")
            .font(.footnote)
            .foregroundStyle(.red)
            .accessibilityIdentifier("coherence.phone.permissions.error")
        }

        if snapshot.readiness.canRequestAccess {
          Button(action: onRequest) {
            if isRequesting {
              ProgressView()
                .frame(maxWidth: .infinity)
            } else {
              Text("Continue to Apple Health")
                .frame(maxWidth: .infinity)
            }
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .disabled(isRequesting)
          .accessibilityIdentifier("coherence.phone.permissions.request")
        } else {
          Button("Continue", action: onContinue)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("coherence.phone.permissions.continue")
        }

        Text(
          "Completing Apple's sheet records that a request occurred. It does not prove that health read access was granted."
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
      }
      .padding(24)
    }
  }
}
