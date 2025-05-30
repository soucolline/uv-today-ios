//
//  AppReducer.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 03/08/2022.
//  Copyright © 2022 Thomas Guilleminot. All rights reserved.
//

import Combine
import Dependencies
import Foundation
import LocationManager
import Models
import Perception
import UVClient

@MainActor
@Perceptible
public class UVScreenViewModel {
  @PerceptionIgnored
  @Dependency(\.uvClient) public var uvClient: UVClient
  @PerceptionIgnored
  @Dependency(\.locationManager) public var locationManager: LocationManager
  
  public var uvIndex: Index = 0
  public var cityName = "loading"
  public var weatherRequestInFlight = false
  public var getCityNameRequestInFlight = false
  public var errorText = ""
  public var userLocation: Models.Location? = nil
  public var isLocationRefused = false
  public var shouldShowErrorPopup = false
  
  public var attributionLogo: URL? = nil
  public var attributionLink: URL? = nil
  
  private var cancellables = Set<AnyCancellable>()
  
  public init() {
    locationManager.location.sink(
      receiveCompletion: { _ in },
      receiveValue: { [weak self] location in
        self?.userLocation = Models.Location(
          latitude: location.coordinate.latitude,
          longitude: location.coordinate.longitude
        )
        
        Task { [self] in
          await self?.getUVRequest()
        }
      }
    )
    .store(in: &cancellables)
    
    locationManager.authorizationStatus
      .sink(receiveValue: { [weak self] result in
        switch result {
        case .success(let status):
          switch status {
          case .authorizedAlways, .authorizedWhenInUse:
            self?.locationManager.getLocation()
            self?.isLocationRefused = false
          case .denied, .restricted:
            self?.shouldShowErrorPopup = true
            self?.errorText = "app.error.localisationDisabled".localized
            self?.isLocationRefused = true
          case .notDetermined:
            self?.weatherRequestInFlight = false
            self?.getCityNameRequestInFlight = false
          @unknown default: break
          }
        case .failure:
          break
        }
      })
      .store(in: &cancellables)
  }
  
  public func onAppear() {
    guard weatherRequestInFlight == false && getCityNameRequestInFlight == false else { return }
    
    showLoading()
    
    isLocationRefused = false
    shouldShowErrorPopup = false
    
    locationManager.requestAuthorisation()
  }
  
  public func onDisappear() {
    locationManager.stop()
  }
  
  public func getUVRequest() async {
    showLoading()
    
    guard let location = userLocation else {
      shouldShowErrorPopup = true
      errorText = "app.error.couldNotLocalise".localized
      return
    }
    
    async let fetchUV = uvClient.fetchUVIndex(request: UVClientRequest(lat: location.latitude, long: location.longitude))
    async let fetchCityName = uvClient.fetchCityName(location: location)
    
    do {
      let (index, name) = try await (fetchUV, fetchCityName)
      
      weatherRequestInFlight = false
      getCityNameRequestInFlight = false
      uvIndex = index
      cityName = name
    } catch let error {
      weatherRequestInFlight = false
      getCityNameRequestInFlight = false
      shouldShowErrorPopup = true
      errorText = error.localizedDescription
      cityName = "app.label.unknown".localized
      uvIndex = 0
    }
  }
  
  public func getAtribution() async {
    do {
      let attribution = try await uvClient.fetchWeatherKitAttribution()
      attributionLogo = attribution.logo
      attributionLink = attribution.link
    } catch {}
  }
  
  private func showLoading() {
    weatherRequestInFlight = true
    getCityNameRequestInFlight = true
  }
}
