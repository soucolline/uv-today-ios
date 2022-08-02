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

let locationManagerReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in

  switch action {
  case .locationManager(.didChangeAuthorization(.authorizedAlways)),
      .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
    state.isLocationPermissionGranted = true
    if state.isRequestingCurrentLocation {
      return environment.locationManager
        .requestLocation()
        .fireAndForget()
    }
    return .none

  case .locationManager(.didChangeAuthorization(.denied)):
    if state.isRequestingCurrentLocation {
      state.errorText = "app.error.localisationDisabled".localized
      state.shouldShowErrorPopup = true
      state.isRequestingCurrentLocation = false
    }
    return .none
  case let .locationManager(.didUpdateLocations(locations)):
    state.isRequestingCurrentLocation = false
    guard let location = locations.first else { return .none }
    state.userLocation = Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    return Effect(value: .getUVRequest)

  default:
    return .none
  }
}
