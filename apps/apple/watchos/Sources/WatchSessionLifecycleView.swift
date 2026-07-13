import CoherenceCore
import SwiftUI

struct WatchSessionLifecycleView: View {
  let projection: MeasurementSessionProjection?
  let errorCode: String?
  let isTransitioning: Bool
  let onStart: () -> Void
  let onPause: () -> Void
  let onResume: () -> Void
  let onEnd: () -> Void
  let onSave: () -> Void
  let onDiscard: () -> Void

  var body: some View {
    VStack(spacing: 8) {
      Text("SYNTHETIC, NO HEALTHKIT")
        .font(.caption2.bold())
        .foregroundStyle(.orange)
        .multilineTextAlignment(.center)
        .accessibilityIdentifier("coherence.watch.session.synthetic-banner")

      Text(stateTitle)
        .font(.headline)
        .multilineTextAlignment(.center)
        .accessibilityIdentifier("coherence.watch.session.state")

      Text(stateDetail)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      Text("No samples captured")
        .font(.caption2.weight(.semibold))
        .accessibilityIdentifier("coherence.watch.session.batch-count")

      controls

      if let errorCode {
        Text("Rehearsal failed: \(errorCode)")
          .font(.caption2)
          .foregroundStyle(.red)
          .multilineTextAlignment(.center)
      }
    }
    .disabled(isTransitioning)
  }

  @ViewBuilder
  private var controls: some View {
    if let projection {
      switch projection.session.state {
      case .prepared:
        Button("Start synthetic rehearsal", action: onStart)
          .accessibilityIdentifier("coherence.watch.session.start")
        Button("Discard synthetic record", action: onDiscard)
          .accessibilityIdentifier("coherence.watch.session.discard")
      case .recording:
        HStack {
          Button("Pause", action: onPause)
            .accessibilityIdentifier("coherence.watch.session.pause")
          Button("End", action: onEnd)
            .accessibilityIdentifier("coherence.watch.session.end")
        }
      case .paused:
        HStack {
          Button("Resume", action: onResume)
            .accessibilityIdentifier("coherence.watch.session.resume")
          Button("End", action: onEnd)
            .accessibilityIdentifier("coherence.watch.session.end")
        }
      case .ended:
        Button("Keep synthetic record", action: onSave)
          .accessibilityIdentifier("coherence.watch.session.save")
        Button("Discard synthetic record", action: onDiscard)
          .accessibilityIdentifier("coherence.watch.session.discard")
      case .saved, .discarded:
        Button("Start another rehearsal", action: onStart)
          .accessibilityIdentifier("coherence.watch.session.restart")
      }
    } else {
      Button("Start synthetic rehearsal", action: onStart)
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("coherence.watch.session.start")
    }
  }

  private var stateTitle: String {
    guard let projection else {
      return "Synthetic rehearsal ready"
    }
    return switch projection.session.state {
    case .prepared:
      "Synthetic session prepared"
    case .recording:
      "Synthetic session active"
    case .paused:
      "Synthetic session paused"
    case .ended:
      "Synthetic session ended"
    case .saved:
      "Synthetic record kept"
    case .discarded:
      "Synthetic record discarded"
    }
  }

  private var stateDetail: String {
    guard let projection else {
      return "Debug-only controls. No workout, samples, or HealthKit."
    }
    return switch projection.session.state {
    case .prepared:
      "The in-memory event log is prepared. No workout or collection has started."
    case .recording:
      "Only lifecycle events are changing. No HealthKit workout or sensor is active."
    case .paused:
      "The synthetic lifecycle is paused. No biometric values exist in this rehearsal."
    case .ended:
      "Choose whether to keep or discard the in-memory synthetic event log."
    case .saved:
      "Kept in memory for this app run. Nothing was written to HealthKit or disk."
    case .discarded:
      "The rehearsal ended as discarded. Nothing was written to HealthKit or disk."
    }
  }
}
