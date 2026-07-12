import SwiftUI

@MainActor
@main
struct CoherenceWatchApp: App {
  private let composition = WatchCompositionRoot.make()

  var body: some Scene {
    WindowGroup {
      WatchRootView(model: composition.model)
    }
  }
}
