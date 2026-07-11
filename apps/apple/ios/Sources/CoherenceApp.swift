import CoherenceCore
import SwiftUI

@main
struct CoherenceApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        ContentUnavailableView {
          Label("Coherence", systemImage: "waveform.path.ecg")
        } description: {
          Text("The Apple capability spike starts here.")
        } actions: {
          Text("Schema version \(SampleBatch.currentSchemaVersion)")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .navigationTitle("Coherence")
      }
    }
  }
}
