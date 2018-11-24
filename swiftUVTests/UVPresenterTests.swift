//
//  UVPresenterTests.swift
//  swiftUVTests
//
//  Created by Zlatan on 18/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import XCTest
import Cuckoo
import CoreLocation

@testable import swiftUV

class UVPresenterTests: XCTestCase {
  
  var presenter: UVPresenterImpl!
  var mockUVView: MockUVViewDelegate!
  var mockLocationService: MockLocationService!
  var mockUVService: MockUVService!
  
  override func setUp() {
    mockUVView = MockUVViewDelegate()
    mockLocationService = MockLocationService(with: CLLocationManager())
    mockUVService = MockUVService()
    
    stub(mockUVView) { stub in
      when(stub).onShowLoader().thenDoNothing()
      when(stub).onDismissLoader().thenDoNothing()
      when(stub).onUpdateLocationWithSuccess(with: any()).thenDoNothing()
      when(stub).onUpdateLocationWithError().thenDoNothing()
      when(stub).onAcceptLocation().thenDoNothing()
      when(stub).onShowRefusedLocation().thenDoNothing()
      when(stub).onReceiveSuccess(index: any(Index.self)).thenDoNothing()
      when(stub).onShowError(message: anyString()).thenDoNothing()
    }
    
    stub(mockLocationService) { stub in
      when(stub).searchLocation().thenDoNothing()
      when(stub).delegate.get.thenCallRealImplementation()
      when(stub).delegate.set(any()).thenCallRealImplementation()
    }
    
    stub(mockUVService) { stub in
      when(stub).getUVIndex(from: any(Location.self), success: any(), failure: any()).thenDoNothing()
    }
    
    presenter = UVPresenterImpl(with: mockLocationService, uvService: mockUVService)
    presenter.setView(view: mockUVView)
  }
  
  func testAcceptLocation() {
    stub(mockLocationService) { stub in
      when(stub).searchLocation().then {
        self.presenter.didAcceptLocationService()
      }
    }
    
    self.getLocation()
    
    verify(mockUVView).onAcceptLocation()
    
    verifyNoMoreInteractions(mockUVView)
    verifyNoMoreInteractions(mockLocationService)
  }
  
  func testRefuseLocation() {
    stub(mockLocationService) { stub in
      when(stub).searchLocation().then {
        self.presenter.didRefuseLocationService()
      }
    }
    
    self.getLocation()
    
    verify(mockUVView).onDismissLoader()
    verify(mockUVView).onShowRefusedLocation()
    
    verifyNoMoreInteractions(mockUVView)
    verifyNoMoreInteractions(mockLocationService)
  }
  
  func testSearchLocationDidFail() {
    stub(mockLocationService) { stub in
      when(stub).searchLocation().then {
        self.presenter.didFailUpdateLocation()
      }
    }
    
    self.getLocation()
    
    verify(mockUVView).onDismissLoader()
    verify(mockUVView).onUpdateLocationWithError()
    
    verifyNoMoreInteractions(mockUVView)
    verifyNoMoreInteractions(mockLocationService)
  }
  
  func testGetUVIndexSucceed() {
    let expectedLocation = Location(latitude: 10.0, longitude: 10.0, city: "Paris")
    let expectedForecast = Forecast(currently: CurrentForecast(uvIndex: 1))
    let mockUVListenerCaptor = ArgumentCaptor<(Forecast) -> Void>()
    
    stub(mockLocationService) { stub in
      when(stub).searchLocation().then {
        self.presenter.didUpdateLocation(expectedLocation)
      }
    }
    
    self.getLocation()
    
    verify(mockUVView).onUpdateLocationWithSuccess(with: ParameterMatcher(matchesFunction: { city in
      city == expectedLocation.city
    }))
    
    verify(mockUVService).getUVIndex(from: ParameterMatcher(matchesFunction: { location in
      location == expectedLocation
    }), success: mockUVListenerCaptor.capture(), failure: any())
    
    mockUVListenerCaptor.value!(expectedForecast)
    
    verify(mockUVView).onDismissLoader()
    verify(mockUVView).onReceiveSuccess(index: ParameterMatcher(matchesFunction: { index in
      index == expectedForecast.currently.uvIndex
    }))
    
    verifyNoMoreInteractions(mockUVView)
    verifyNoMoreInteractions(mockLocationService)
    verifyNoMoreInteractions(mockUVService)
  }
  
  func testGetUVIndexFailure() {
    let expectedLocation = Location(latitude: 10.0, longitude: 10.0, city: "Paris")
    let mockUVListenerCaptor = ArgumentCaptor<(Error) -> Void>()
    
    stub(mockLocationService) { stub in
      when(stub).searchLocation().then {
        self.presenter.didUpdateLocation(expectedLocation)
      }
    }
    
    self.getLocation()
    
    verify(mockUVView).onUpdateLocationWithSuccess(with: ParameterMatcher(matchesFunction: { city in
      city == expectedLocation.city
    }))
    
    verify(mockUVService).getUVIndex(from: ParameterMatcher(matchesFunction: { location in
      location == expectedLocation
    }), success: any(), failure: mockUVListenerCaptor.capture())
    
    mockUVListenerCaptor.value!(UVError.noData)
    
    verify(mockUVView).onDismissLoader()
    verify(mockUVView).onShowError(message: anyString())
    
    verifyNoMoreInteractions(mockUVView)
    verifyNoMoreInteractions(mockLocationService)
    verifyNoMoreInteractions(mockUVService)
  }
  
  private func getLocation() {
    self.presenter.searchLocation()
    
    verify(mockLocationService).delegate.set(any())
    verify(mockUVView).onShowLoader()
    verify(mockLocationService).searchLocation()
  }
  
}
