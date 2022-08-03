//
//  ContentVIew.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 31/07/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import ComposableArchitecture
import ComposableCoreLocation
import SwiftUI

struct AppState: Equatable {
  var uvIndex: Index = 0
  var cityName = "loading"
  var weatherRequestInFlight = false
  var getCityNameRequestInFlight = false
  var shouldShowErrorPopup = false
  var errorText = ""

  var userLocation: Location?
  var isRequestingCurrentLocation = false
  var isLocationPermissionGranted = false
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
.debug()

struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        Rectangle()
          .animation(Animation.easeIn(duration: 1.0))
          .foregroundColor(Color(viewStore.uvIndex.associatedColor))
          .edgesIgnoringSafeArea(.all)

        VStack {
          HStack {
            Spacer()
            Image(systemName: "arrow.clockwise")
              .resizable()
              .frame(width: 20, height: 20, alignment: .center)
              .font(Font.title.weight(Font.Weight.thin))
              .foregroundColor(.white)
              .padding(.trailing, 20)
              .onTapGesture {
                viewStore.send(.getUVRequest)
              }
          }

          HStack {
            Text(viewStore.cityName)
              .padding(.top, 33)
              .font(.system(size: 38, weight: .bold, design: .rounded))
              .foregroundColor(.white)
              .padding(.horizontal, 20)
              .lineLimit(1)
              .minimumScaleFactor(0.2)
              .redacted(reason: viewStore.getCityNameRequestInFlight ? .placeholder : [])
            Spacer()
          }

          Spacer()

          Text(String(viewStore.uvIndex))
            .foregroundColor(.white)
            .font(.system(size: 80, weight: .semibold, design: .rounded))
            .redacted(reason: viewStore.weatherRequestInFlight ? .placeholder : [])

          Spacer()
          Text(viewStore.uvIndex.associatedDescription)
            .padding(20)
            .foregroundColor(.white)
            .font(.system(size: 12))
            .redacted(reason: viewStore.weatherRequestInFlight ? .placeholder : [])
        }
      }
      .alert(isPresented: viewStore.binding(get: \.shouldShowErrorPopup, send: .dismissErrorPopup)) {
        Alert(title: Text("app.label.error"), message: Text(viewStore.errorText))
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(
          uvIndex: 1,
          cityName: "Gueugnon",
          weatherRequestInFlight: false,
          getCityNameRequestInFlight: false
        ),
        reducer: appReducer,
        environment: AppEnvironment(
          uvClient: .mock,
          dispatchQueue: DispatchQueue.test.eraseToAnyScheduler(),
          locationManager: .live
        )
      )
    )
  }
}
