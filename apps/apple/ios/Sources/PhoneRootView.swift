import SwiftUI

struct PhoneRootView: View {
  let model: PhoneAppModel

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Image(systemName: "waveform.path.ecg")
          .font(.system(size: 52))
          .foregroundStyle(.green)

        Text("Interpersonal measurement, with consent")
          .font(.headline)
          .multilineTextAlignment(.center)

        Text(model.sensorMode.displayName)
          .font(.subheadline)
          .foregroundStyle(model.sensorMode == .synthetic ? .orange : .secondary)
          .accessibilityIdentifier("coherence.phone.sensor-mode")

        Text("Schema version \(model.schemaVersion)")
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("coherence.phone.schema-version")
      }
      .padding(24)
      .navigationTitle("Coherence")
    }
  }
}

#Preview {
  PhoneRootView(
    model: PhoneCompositionRoot.make(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    ).model
  )
}
