import SwiftUI

struct PhoneDiagnosticsView: View {
  let snapshot: AppleDiagnosticSnapshot
  let json: String
  let onBack: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Button("Back", systemImage: "chevron.left", action: onBack)
          .buttonStyle(.plain)

        VStack(alignment: .leading, spacing: 8) {
          Text("Privacy-safe diagnostics")
            .font(.largeTitle.bold())
            .accessibilityIdentifier("coherence.phone.diagnostics.title")
          Text(
            "This export contains application and capability state. It excludes biometric values, participant identity, and persistent device identifiers."
          )
          .foregroundStyle(.secondary)
        }

        LabeledContent("Run identifier", value: snapshot.runIdentifier.uuidString)
          .font(.caption)
          .accessibilityIdentifier("coherence.phone.diagnostics.run-id")
        LabeledContent("Evidence", value: snapshot.evidenceSource)
        LabeledContent("Platform", value: snapshot.platform)
        LabeledContent(
          "Biometric values",
          value: snapshot.biometricValuesIncluded ? "Included" : "Excluded"
        )
        .accessibilityIdentifier("coherence.phone.diagnostics.redaction")

        ShareLink(
          item: json,
          subject: Text("Coherence diagnostic JSON"),
          message: Text("Privacy-safe Coherence capability diagnostics")
        ) {
          Label("Share diagnostic JSON", systemImage: "square.and.arrow.up")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityIdentifier("coherence.phone.diagnostics.export")

        DisclosureGroup("JSON preview") {
          Text(json)
            .font(.caption.monospaced())
            .textSelection(.enabled)
            .padding(.top, 8)
        }
      }
      .padding(24)
    }
  }
}
