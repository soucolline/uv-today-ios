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
    let mainQueue = DispatchQueue.test
    let expectedForecast = Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5)
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true,
          userLocation: Location(latitude: 12.0, longitude: 13.0)
        ),
      reducer: appReducer,
      environment: AppEnvironment(
        uvClient: .mock,
        dispatchQueue: mainQueue.eraseToAnyScheduler(),
        locationManager: .live
      )
    )
    
    store.send(.getUVRequest) {
      $0.weatherRequestInFlight = true
      $0.getCityNameRequestInFlight = true
    }
    
    mainQueue.advance()
    
    store.receive(.getUVResponse(.success(expectedForecast))) {
      $0.weatherRequestInFlight = false
      $0.uvIndex = 5
    }
    
    mainQueue.advance()
    
    store.receive(.getCityNameResponse(.success("Gueugnon"))) {
      $0.getCityNameRequestInFlight = false
      $0.cityName = "Gueugnon"
    }
  }
  
  func testGetUVRequestFailure() {
    let mainQueue = DispatchQueue.test
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true,
          userLocation: Location(latitude: 12.0, longitude: 13.0)
        ),
      reducer: appReducer,
      environment: AppEnvironment(
        uvClient: UVClient(fetchUVIndex: { _ in return Effect(error: UVClient.Failure(errorDescription: "test"))}, fetchCityName: { _ in fatalError()}),
        dispatchQueue: mainQueue.eraseToAnyScheduler(),
        locationManager: .live
      )
    )
    
    store.send(.getUVRequest) {
      $0.weatherRequestInFlight = true
      $0.getCityNameRequestInFlight = true
    }
    
    mainQueue.advance()
    
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
      environment: AppEnvironment(
        uvClient: .mock,
        dispatchQueue: DispatchQueue.main.eraseToAnyScheduler(),
        locationManager: .live
      )
    )
    
    store.send(.getUVRequest) {
      $0.weatherRequestInFlight = true
      $0.shouldShowErrorPopup = true
      $0.errorText = "app.error.couldNotLocalise".localized
    }
  }
  
  func testGetUVResponseSuccess() {
    let mainQueue = DispatchQueue.test
    let expectedForecast = Forecast(lat: 12.0, lon: 13.0, dateIso: "32323", date: 1234, value: 5)
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true,
          userLocation: Location(latitude: 12.0, longitude: 13.0)
        ),
      reducer: appReducer,
      environment: AppEnvironment(
        uvClient: .mock,
        dispatchQueue: mainQueue.eraseToAnyScheduler(),
        locationManager: .live
      )
    )
    
    store.send(.getUVResponse(.success(expectedForecast))) {
      $0.weatherRequestInFlight = false
      $0.uvIndex = 5
    }
    
    mainQueue.advance()
    
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
      environment: AppEnvironment(
        uvClient: .mock,
        dispatchQueue: DispatchQueue.test.eraseToAnyScheduler(),
        locationManager: .live
      )
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
      environment: AppEnvironment(
        uvClient: .mock,
        dispatchQueue: DispatchQueue.test.eraseToAnyScheduler(),
        locationManager: .live
      )
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
      initialState:
        AppState(
          getCityNameRequestInFlight: true
        ),
      reducer: appReducer,
      environment: AppEnvironment(
        uvClient: .mock,
        dispatchQueue: DispatchQueue.test.eraseToAnyScheduler(),
        locationManager: .live
      )
    )
    
    store.send(.getCityNameResponse(.success("Gueugnon"))) {
      $0.getCityNameRequestInFlight = false
      $0.cityName = "Gueugnon"
    }
  }
  
  func testGetCityNameResponseFailure() {
    let store = TestStore(
      initialState:
        AppState(
          getCityNameRequestInFlight: true
        ),
      reducer: appReducer,
      environment: AppEnvironment(
        uvClient: .mock,
        dispatchQueue: DispatchQueue.test.eraseToAnyScheduler(),
        locationManager: .live
      )
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
      environment: AppEnvironment(
        uvClient: .mock,
        dispatchQueue: DispatchQueue.test.eraseToAnyScheduler(),
        locationManager: .live
      )
    )
    
    store.send(.dismissErrorPopup) {
      $0.shouldShowErrorPopup = false
    }
  }
}
