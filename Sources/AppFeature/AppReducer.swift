//
//  AppReducer.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 03/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import ComposableCoreLocation
import LocationManager
import Models
import UVClient

public struct AppReducer: ReducerProtocol {
  public struct State: Equatable {
    public var uvIndex: Index
    public var cityName: String
    public var weatherRequestInFlight: Bool
    public var getCityNameRequestInFlight: Bool
    public var attributionLogo: URL?
    public var attributionLink: URL?
    public var errorText: String
    public var userLocation: Models.Location?
    public var isRequestingCurrentLocation: Bool
    public var hasAlreadyRequestLocation: Bool
    public var isLocationRefused: Bool
    
    @BindableState public var shouldShowErrorPopup: Bool
    
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
  
  public enum Action: Equatable, BindableAction {
    case getUVRequest
    case getUVResponse(TaskResult<Index>)
    case getCityNameResponse(TaskResult<String>)
    case getAttribution
    case getAttributionResponse(TaskResult<AttributionResponse>)

    case onAppear
    case onDisappear
    case locationManager(LocationManager.Action)
    case binding(BindingAction<State>)
  }
  
  @Dependency(\.uvClient) public var uvClient: UVClient
  @Dependency(\.locationManager) public var locationManager: LocationManager
  
  public init() {}
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.weatherRequestInFlight = true
        state.getCityNameRequestInFlight = true
        state.isRequestingCurrentLocation = true
        state.isLocationRefused = false
        
        switch locationManager.authorizationStatus() {
        case .notDetermined:
          return .merge(
              locationManager
                .delegate()
                .map(AppReducer.Action.locationManager),
      
              locationManager
                .requestWhenInUseAuthorization()
                .fireAndForget()
            )

        case .authorizedAlways, .authorizedWhenInUse:
          return .merge(
              locationManager
                .delegate()
                .map(AppReducer.Action.locationManager),
      
              locationManager
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
            .getUVResponse(TaskResult { try await uvClient.fetchUVIndex(UVClientRequest(lat: location.latitude, long: location.longitude)) })
          )
          
          async let fetchCityName: Void = send(
            .getCityNameResponse(TaskResult { try await uvClient.fetchCityName(location) })
          )
          
          _ = await [fetchUV, fetchCityName]
        }

      case .getUVResponse(.success(let index)):
        state.weatherRequestInFlight = false
        state.uvIndex = index
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
        
      case .getCityNameResponse(.failure):
        state.getCityNameRequestInFlight = false
        state.cityName = "app.label.unknown".localized
        return .none
        
      case .getAttribution:
        return .task {
          await .getAttributionResponse(TaskResult { try await uvClient.fetchWeatherKitAttribution() })
        }
        
      case .getAttributionResponse(.success(let attribution)):
        state.attributionLogo = attribution.logo
        state.attributionLink = attribution.link
        return .none
        
      case .getAttributionResponse(.failure):
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
    ._printChanges()
    
    LocationReducer()
  }
}
