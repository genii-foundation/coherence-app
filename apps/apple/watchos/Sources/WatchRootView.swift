import SwiftUI

struct WatchRootView: View {
  let model: WatchAppModel

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: "waveform.path.ecg")
        .font(.title2)
        .foregroundStyle(.green)

      Text("Coherence")
        .font(.headline)

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
    .padding()
  }
}

#Preview {
  WatchRootView(
    model: WatchCompositionRoot.make(
      arguments: [AppleRuntimeConfiguration.fakeSensorArgument]
    ).model
  )
}
