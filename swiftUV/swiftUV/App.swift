//
//  App.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 04/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import AppFeature
import ComposableArchitecture
import SwiftUI
import FirebaseCore

@main
struct SwiftUVApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      UVScene()
    }
  }
}

private struct UVScene: View {
  @State private var store = Store(initialState: UVFeature.State()) { UVFeature() }

  var body: some View {
    UVScreen(store: store)
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
