//
//  File.swift
//  
//
//  Created by Thomas Guilleminot on 16/10/2022.
//

import Dependencies
import Foundation

package enum LocationManagerKey: DependencyKey {
  package static let liveValue = LocationManager()
}

public extension DependencyValues {
  var locationManager: LocationManager {
    get { self[LocationManagerKey.self] }
    set { self[LocationManagerKey.self] = newValue }
  }
}
