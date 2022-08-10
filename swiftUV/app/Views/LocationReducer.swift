//
//  LocationReducer.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import ComposableCoreLocation
import Foundation

let locationManagerReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
  switch action {
  case let .locationManager(.didUpdateLocations(locations)):
    guard state.hasAlreadyRequestLocation == false else {
      return .none
    }
    
    state.isRequestingCurrentLocation = false
    guard let location = locations.first else { return .none }
    state.userLocation = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    state.hasAlreadyRequestLocation = true
    return .task { .getUVRequest }

  default:
    return .none
  }
}
