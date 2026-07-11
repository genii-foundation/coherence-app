import CoherenceCore
import SwiftUI

@main
struct CoherenceWatchApp: App {
  var body: some Scene {
    WindowGroup {
      VStack(spacing: 8) {
        Image(systemName: "waveform.path.ecg")
          .font(.title2)
          .foregroundStyle(.green)
        Text("Coherence")
          .font(.headline)
        Text("Measurement sessions are the first capability spike.")
          .font(.caption2)
          .multilineTextAlignment(.center)
        Text("Schema \(SampleBatch.currentSchemaVersion)")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      .padding()
    }
  }
}
