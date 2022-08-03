//
//  AppReducer.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 03/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import ComposableCoreLocation

struct AppState: Equatable {
  var uvIndex: Index = 0
  var cityName = "loading"
  var weatherRequestInFlight = false
  var getCityNameRequestInFlight = false
  var shouldShowErrorPopup = false
  var errorText = ""

  var userLocation: Location?
  var isRequestingCurrentLocation = false
  var isLocationRefused = false
}

enum AppAction: Equatable {
  case getUVRequest
  case getUVResponse(Result<Forecast, UVClient.Failure>)
  case getCityNameResponse(Result<String, UVClient.Failure>)
  case dismissErrorPopup

  case onAppear
  case locationManager(LocationManager.Action)
}

struct AppEnvironment {
  var uvClient: UVClient
  var dispatchQueue: AnySchedulerOf<DispatchQueue>
  var locationManager: LocationManager
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .onAppear:
    state.weatherRequestInFlight = true
    state.getCityNameRequestInFlight = true
    state.isRequestingCurrentLocation = true
    state.isLocationRefused = false
    
    switch environment.locationManager.authorizationStatus() {
    case .notDetermined:
      state.isRequestingCurrentLocation = true
      
      return .merge(
          environment.locationManager
            .delegate()
            .map(AppAction.locationManager),
  
          environment.locationManager
            .requestWhenInUseAuthorization()
            .fireAndForget()
        )

    case .authorizedAlways, .authorizedWhenInUse:
      return .merge(
          environment.locationManager
            .delegate()
            .map(AppAction.locationManager),
  
          environment.locationManager
            .requestLocation()
            .fireAndForget()
        )

    case .restricted, .denied:
      state.shouldShowErrorPopup = true
      state.errorText = "app.error.localisationDisabled".localized
      state.isLocationRefused = true
      return .none
    
    @unknown default:
      return .none
    }
    
  case .getUVRequest:
    state.weatherRequestInFlight = true
    state.getCityNameRequestInFlight = true
    
    guard let location = state.userLocation else {
      state.shouldShowErrorPopup = true
      state.errorText = "app.error.couldNotLocalise".localized
      return .none
    }
    
    return environment.uvClient
      .fetchUVIndex(UVClientRequest(lat: location.latitude, long: location.longitude))
      .receive(on: DispatchQueue.main)
      .catchToEffect()
      .map { .getUVResponse($0) }

  case .getUVResponse(.success(let forecast)):
    state.weatherRequestInFlight = false
    state.uvIndex = Int(forecast.value)
    
    guard let location = state.userLocation else {
      state.cityName = "app.label.unknown".localized
      return .none
    }
    
    return environment.uvClient
      .fetchCityName(location)
      .receive(on: DispatchQueue.main)
      .catchToEffect()
      .map { .getCityNameResponse($0) }
    
  case .getUVResponse(.failure(let error)):
    state.weatherRequestInFlight = false
    state.shouldShowErrorPopup = true
    state.errorText = error.errorDescription
    state.uvIndex = 0
    return .none
      
  case .getCityNameResponse(.success(let city)):
    state.getCityNameRequestInFlight = false
    state.cityName = city
    return .none
    
  case .getCityNameResponse(.failure(let error)):
    state.getCityNameRequestInFlight = false
    state.cityName = "app.label.unknown".localized
    return .none
    
  case .dismissErrorPopup:
    state.shouldShowErrorPopup = false
    return .none
    
  case .locationManager:
    return .none
  }
}
.combined(
  with:
    locationManagerReducer
    .pullback(state: \.self, action: /AppAction.self, environment: { $0 })
)
