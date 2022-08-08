//
//  AppReducerTests.swift
//  swiftUVTests
//
//  Created by Thomas Guilleminot on 04/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import Foundation
import ComposableArchitecture
import XCTest

@testable import swiftUV

class AppReducerTests: XCTestCase {
  
  func testGetUVRequestSuccess() {
    let expectedForecast = Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5)
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true,
          userLocation: Location(latitude: 12.0, longitude: 13.0)
        ),
      reducer: appReducer,
      environment: .unimplemented
    )
    
    store.environment.uvClient.fetchUVIndex = { _ in Effect(value: Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5)) }
    store.environment.uvClient.fetchCityName = { _ in Effect(value: "Gueugnon") }
    store.environment.dispatchQueue = .immediate
    
    store.send(.getUVRequest) {
      $0.weatherRequestInFlight = true
      $0.getCityNameRequestInFlight = true
    }
    
    store.receive(.getUVResponse(.success(expectedForecast))) {
      $0.weatherRequestInFlight = false
      $0.uvIndex = 5
    }
    
    store.receive(.getCityNameResponse(.success("Gueugnon"))) {
      $0.getCityNameRequestInFlight = false
      $0.cityName = "Gueugnon"
    }
  }
  
  func testGetUVRequestFailure() {
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true,
          userLocation: Location(latitude: 12.0, longitude: 13.0)
        ),
      reducer: appReducer,
      environment: .unimplemented
    )
    
    store.environment.uvClient.fetchUVIndex = { _ in Effect(error: UVClient.Failure(errorDescription: "test")) }
    store.environment.dispatchQueue = .immediate
    
    store.send(.getUVRequest) {
      $0.weatherRequestInFlight = true
      $0.getCityNameRequestInFlight = true
    }
    
    store.receive(.getUVResponse(.failure(UVClient.Failure(errorDescription: "test")))) {
      $0.weatherRequestInFlight = false
      $0.shouldShowErrorPopup = true
      $0.errorText = "test"
      $0.uvIndex = 0
    }
  }
  
  func testGetUVRequestFailureNoLocation() {
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true
        ),
      reducer: appReducer,
      environment: .unimplemented
    )
    
    store.send(.getUVRequest) {
      $0.weatherRequestInFlight = true
      $0.shouldShowErrorPopup = true
      $0.errorText = "app.error.couldNotLocalise".localized
    }
  }
  
  func testGetUVResponseSuccess() {
    let expectedForecast = Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5)
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true,
          userLocation: Location(latitude: 12.0, longitude: 13.0)
        ),
      reducer: appReducer,
      environment: .unimplemented
    )
    
    store.environment.uvClient.fetchCityName = { _ in Effect(value: "Gueugnon") }
    store.environment.dispatchQueue = .immediate
    
    store.send(.getUVResponse(.success(expectedForecast))) {
      $0.weatherRequestInFlight = false
      $0.uvIndex = 5
    }
    
    store.receive(.getCityNameResponse(.success("Gueugnon"))) {
      $0.cityName = "Gueugnon"
      $0.getCityNameRequestInFlight = false
    }
  }
  
  func testGetUVResponseSuccessNoLocation() {
    let expectedForecast = Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5)
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true
        ),
      reducer: appReducer,
      environment: .unimplemented
    )
    
    store.send(.getUVResponse(.success(expectedForecast))) {
      $0.weatherRequestInFlight = false
      $0.uvIndex = 5
      $0.cityName = "app.label.unknown".localized
    }
  }
  
  func testGetUVResponseFailure() {
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true
        ),
      reducer: appReducer,
      environment: .unimplemented
    )
    
    store.send(.getUVResponse(.failure(UVClient.Failure(errorDescription: "test")))) {
      $0.weatherRequestInFlight = false
      $0.shouldShowErrorPopup = true
      $0.errorText = "test"
      $0.uvIndex = 0
    }
  }
  
  func testGetCityNameResponseSuccess() {
    let store = TestStore(
      initialState: .init(),
      reducer: appReducer,
      environment: .unimplemented
    )
    
    store.send(.getCityNameResponse(.success("Gueugnon"))) {
      $0.getCityNameRequestInFlight = false
      $0.cityName = "Gueugnon"
    }
  }
  
  func testGetCityNameResponseFailure() {
    let store = TestStore(
      initialState: .init(),
      reducer: appReducer,
      environment: .unimplemented
    )
    
    store.send(.getCityNameResponse(.failure(UVClient.Failure(errorDescription: "test")))) {
      $0.getCityNameRequestInFlight = false
      $0.cityName = "app.label.unknown".localized
    }
  }
    
  func testDismissErrorPopup() {
    let store = TestStore(
      initialState:
        AppState(
          shouldShowErrorPopup: true
        ),
      reducer: appReducer,
      environment: .unimplemented
    )
    
    store.send(.dismissErrorPopup) {
      $0.shouldShowErrorPopup = false
    }
  }
}
extension AppEnvironment {
  static let unimplemented = Self(
    uvClient: .unimplemented,
    dispatchQueue: .unimplemented,
    locationManager: .failing
  )
}
