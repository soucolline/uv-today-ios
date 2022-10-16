//
//  App.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 04/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import AppFeature
import SwiftUI
import ComposableArchitecture
import Bugsnag

@main
struct SwiftUVApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(
          initialState: AppReducer.State(),
          reducer: AppReducer(uvClient: .live, locationManager: .live)
        )
      )
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if RELEASE
        Bugsnag.start(withApiKey: "b6ee27da8e2f6e0b9641e9c2f2fc6d41")
        #endif
        return true
    }
}
