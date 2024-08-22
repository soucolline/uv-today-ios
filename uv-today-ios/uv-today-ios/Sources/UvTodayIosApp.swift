import SwiftUI
import AppFeature
import Perception
import SwiftUI
import FirebaseCore

@main
struct UvTodayIosApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WithPerceptionTracking {
      WindowGroup {
        ContentView(
          viewModel: UVViewModel()
        )
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
