//
//  App.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 04/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import AppFeature
import Perception
import SwiftUI
import FirebaseCore

@main
struct SwiftUVApp: App {
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
