import SwiftUI

struct PhonePrivacyView: View {
  let onContinue: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Image(systemName: "hand.raised.fill")
          .font(.system(size: 44))
          .foregroundStyle(.green)

        VStack(alignment: .leading, spacing: 10) {
          Text("Measurement begins with your choice")
            .font(.largeTitle.bold())
            .accessibilityIdentifier("coherence.phone.privacy.title")

          Text(
            "Coherence is designed for explicit, participant-directed measurement. It does not collect a hidden stream or assign a score to you."
          )
          .foregroundStyle(.secondary)
        }

        PrivacyPrinciple(
          icon: "person.crop.circle.badge.checkmark",
          title: "You remain the participant",
          detail:
            "Access requests, measurement sessions, and future sharing each require a clear purpose."
        )

        PrivacyPrinciple(
          icon: "heart.text.square",
          title: "Minimum access first",
          detail:
            "The first phone request is limited to heart rate history. Other data types require their own product purpose."
        )

        PrivacyPrinciple(
          icon: "eye.slash",
          title: "No permission guesswork",
          detail:
            "Apple does not reveal individual health read decisions to applications. Coherence will never pretend otherwise."
        )

        Button("Review requested access", action: onContinue)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .frame(maxWidth: .infinity)
          .accessibilityIdentifier("coherence.phone.privacy.continue")
      }
      .padding(24)
    }
  }
}

private struct PrivacyPrinciple: View {
  let icon: String
  let title: String
  let detail: String

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(.green)
        .frame(width: 30)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
        Text(detail)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
  }
}
