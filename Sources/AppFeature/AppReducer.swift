//
//  AppReducer.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 03/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import ComposableCoreLocation
import Models
import UVClient

public struct AppState: Equatable {
  public var uvIndex: Index
  public var cityName: String
  public var weatherRequestInFlight: Bool
  public var getCityNameRequestInFlight: Bool
  public var errorText: String

  public var userLocation: Models.Location?
  public var isRequestingCurrentLocation: Bool
  public var hasAlreadyRequestLocation: Bool
  public var isLocationRefused: Bool
  
  @BindableState public var shouldShowErrorPopup = false
  
  public init(
    uvIndex: Index = 0,
    cityName: String = "loading",
    weatherRequestInFlight: Bool = false,
    getCityNameRequestInFlight: Bool = false,
    errorText: String = "",
    userLocation: Models.Location? = nil,
    isRequestingCurrentLocation: Bool = false,
    hasAlreadyRequestLocation: Bool = false,
    isLocationRefused: Bool = false,
    shouldShowErrorPopup: Bool = false
  ) {
    self.uvIndex = uvIndex
    self.cityName = cityName
    self.weatherRequestInFlight = weatherRequestInFlight
    self.getCityNameRequestInFlight = getCityNameRequestInFlight
    self.errorText = errorText

    self.userLocation = userLocation
    self.isRequestingCurrentLocation = isRequestingCurrentLocation
    self.hasAlreadyRequestLocation = hasAlreadyRequestLocation
    self.isLocationRefused = isLocationRefused
    self.shouldShowErrorPopup = shouldShowErrorPopup
  }
}

public enum AppAction: Equatable, BindableAction {
  case getUVRequest
  case getUVResponse(TaskResult<Forecast>)
  case getCityNameResponse(TaskResult<String>)

  case onAppear
  case onDisappear
  case locationManager(LocationManager.Action)
  case binding(BindingAction<AppState>)
}

public struct AppEnvironment {
  public var uvClient: UVClient
  public var locationManager: LocationManager
  
  public init(uvClient: UVClient, locationManager: LocationManager) {
    self.uvClient = uvClient
    self.locationManager = locationManager
  }
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .onAppear:
    state.weatherRequestInFlight = true
    state.getCityNameRequestInFlight = true
    state.isRequestingCurrentLocation = true
    state.isLocationRefused = false
    
    switch environment.locationManager.authorizationStatus() {
    case .notDetermined:
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
    
  case .onDisappear:
    state.hasAlreadyRequestLocation = false
    return .none
    
  case .getUVRequest:
    state.weatherRequestInFlight = true
    state.getCityNameRequestInFlight = true
    
    guard let location = state.userLocation else {
      state.shouldShowErrorPopup = true
      state.errorText = "app.error.couldNotLocalise".localized
      return .none
    }
    
    return .run { send in
      async let fetchUV: Void = send(
        .getUVResponse(TaskResult { try await environment.uvClient.fetchUVIndex(UVClientRequest(lat: location.latitude, long: location.longitude)) })
      )
      
      async let fetchCityName: Void = send(
        .getCityNameResponse(TaskResult { try await environment.uvClient.fetchCityName(location) })
      )
      
      _ = await [fetchUV, fetchCityName]
    }

  case .getUVResponse(.success(let forecast)):
    state.weatherRequestInFlight = false
    state.uvIndex = Int(forecast.value)
    return .none
    
  case .getUVResponse(.failure(let error)):
    state.weatherRequestInFlight = false
    state.shouldShowErrorPopup = true
    state.errorText = error.localizedDescription
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
    
  case .binding(\.$shouldShowErrorPopup):
    state.shouldShowErrorPopup = false
    return .none
    
  case .binding:
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
.binding()
.debug()
