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
import Models

struct LocationReducer: ReducerProtocol {
  typealias State = AppReducer.State
  typealias Action = AppReducer.Action
  
  func reduce(into state: inout AppReducer.State, action: AppReducer.Action) -> Effect<AppReducer.Action, Never> {
    switch action {
    case let .locationManager(.didUpdateLocations(locations)):
      guard state.hasAlreadyRequestLocation == false else {
        return .none
      }
      
      state.isRequestingCurrentLocation = false
      guard let location = locations.first else { return .none }
      state.userLocation = Models.Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      state.hasAlreadyRequestLocation = true
      return .task { .getUVRequest }

    default:
      return .none
    }
  }
}
