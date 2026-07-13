import SwiftUI

struct PhoneRootView: View {
  let model: PhoneAppModel

  var body: some View {
    NavigationStack {
      Group {
        switch model.destination {
        case .privacy:
          PhonePrivacyView(onContinue: model.continueFromPrivacy)
        case .permissions:
          PhonePermissionsView(
            snapshot: model.authorizationSnapshot,
            errorCode: model.authorizationErrorCode,
            isRequesting: model.isRequestingAuthorization,
            onBack: model.showPrivacy,
            onRequest: {
              Task { await model.requestAuthorization() }
            },
            onContinue: model.showOverview
          )
        case .overview:
          PhoneOverviewView(
            sensorMode: model.sensorMode,
            schemaVersion: model.schemaVersion,
            authorizationSnapshot: model.authorizationSnapshot,
            onReviewAccess: model.showPermissions,
            onShowDiagnostics: model.showDiagnostics
          )
        case .diagnostics:
          PhoneDiagnosticsView(
            snapshot: model.diagnosticSnapshot,
            json: model.diagnosticJSON,
            onBack: model.showOverview
          )
        }
      }
      .navigationTitle("Coherence")
    }
    .task {
      await model.refreshAuthorization()
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
