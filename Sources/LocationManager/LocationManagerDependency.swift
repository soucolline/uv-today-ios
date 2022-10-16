//
//  File.swift
//  
//
//  Created by Thomas Guilleminot on 16/10/2022.
//

import ComposableCoreLocation
import Foundation

private enum LocationManagerKey: DependencyKey {
  static var liveValue = LocationManager.live
  static var testValue = LocationManager.failing
}

public extension DependencyValues {
  var locationManager: LocationManager {
    get { self[LocationManagerKey.self] }
    set { self[LocationManagerKey.self] = newValue }
  }
}
