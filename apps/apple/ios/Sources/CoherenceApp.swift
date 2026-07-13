import SwiftUI

@MainActor
@main
struct CoherenceApp: App {
  private let composition = PhoneCompositionRoot.make()

  var body: some Scene {
    WindowGroup {
      PhoneRootView(model: composition.model)
    }
  }
}
