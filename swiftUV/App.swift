//
//  App.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 04/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Bugsnag
import Keys

@main
struct SwiftUVApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(
          initialState: AppState(),
          reducer: appReducer,
          environment: AppEnvironment(
            uvClient: .live,
            dispatchQueue: .main,
            locationManager: .live
          )
        )
      )
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if RELEASE
        Bugsnag.start(withApiKey: SwiftUVKeys().bugsnagApiKey)
        #endif
        return true
    }
}
