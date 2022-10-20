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
import AppFeature
import Models

@MainActor
class AppReducerTests: XCTestCase {
  func testGetUVRequestSuccess() async {
    let store = TestStore(
      initialState:
        AppReducer.State(
          getCityNameRequestInFlight: true,
          userLocation: Location(latitude: 12.0, longitude: 13.0)
        ),
      reducer: AppReducer()
    )
    
    store.dependencies.uvClient.fetchUVIndex = { _ in 5 }
    store.dependencies.uvClient.fetchCityName = { _ in "Gueugnon" }
    
    await store.send(.getUVRequest) {
      $0.weatherRequestInFlight = true
      $0.getCityNameRequestInFlight = true
    }
    
    await store.receive(.getUVResponse(.success(5))) {
      $0.weatherRequestInFlight = false
      $0.uvIndex = 5
    }
    
    await store.receive(.getCityNameResponse(.success("Gueugnon"))) {
      $0.getCityNameRequestInFlight = false
      $0.cityName = "Gueugnon"
    }
  }
  
  func testGetUVRequestFailure() async {
    let store = TestStore(
      initialState:
        AppReducer.State(
          getCityNameRequestInFlight: true,
          userLocation: Location(latitude: 12.0, longitude: 13.0)
        ),
      reducer: AppReducer()
    )
    
    store.dependencies.uvClient.fetchUVIndex = { _ in throw "test" }
    store.dependencies.uvClient.fetchCityName = { _ in throw "no city" }
    
    await store.send(.getUVRequest) {
      $0.weatherRequestInFlight = true
      $0.getCityNameRequestInFlight = true
    }
    
    await store.receive(.getUVResponse(.failure("test"))) {
      $0.weatherRequestInFlight = false
      $0.shouldShowErrorPopup = true
      $0.errorText = "test"
      $0.uvIndex = 0
    }
    
    await store.receive(.getCityNameResponse(.failure("no city"))) {
      $0.getCityNameRequestInFlight = false
      $0.cityName = "app.label.unknown".localized
    }
  }
  
  func testGetUVRequestFailureNoLocation() {
    let store = TestStore(
      initialState:
        AppReducer.State(
          getCityNameRequestInFlight: true
        ),
      reducer: AppReducer()
    )
    
    store.send(.getUVRequest) {
      $0.weatherRequestInFlight = true
      $0.shouldShowErrorPopup = true
      $0.errorText = "app.error.couldNotLocalise".localized
    }
  }
    
  func testDismissErrorPopup() {
    let store = TestStore(
      initialState:
        AppReducer.State(
          shouldShowErrorPopup: true
        ),
      reducer: AppReducer()
    )
    
    store.send(.set(\.$shouldShowErrorPopup, true)) {
      $0.shouldShowErrorPopup = false
    }
  }
  
  func testOnDisappear() {
    let store = TestStore(
      initialState: AppReducer.State(hasAlreadyRequestLocation: true),
      reducer: AppReducer()
    )
    
    store.send(.onDisappear) {
      $0.hasAlreadyRequestLocation = false
    }
  }
}

extension String: Error {}
extension String: LocalizedError {
  public var errorDescription: String? { self }
}
