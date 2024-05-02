//
//  File.swift
//  
//
//  Created by Thomas Guilleminot on 20/04/2024.
//

import Combine
import CoreLocation
import Foundation

public enum LocationManagerError: Error {
  case notAuthorised
}

public class LocationManager: NSObject, CLLocationManagerDelegate {
  public var authorizationStatus = PassthroughSubject<Result<CLAuthorizationStatus, Error>, Never>()
  public var location = PassthroughSubject<CLLocation, Error>()
  
  private let locationManager = CLLocationManager()
  
  public override init() {
    super.init()
    authorizationStatus.send(.success(locationManager.authorizationStatus))
    locationManager.delegate = self
  }
  
  public func requestAuthorisation() {
    switch locationManager.authorizationStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .authorizedAlways, .authorizedWhenInUse, .denied, .restricted:
      authorizationStatus.send(.success(locationManager.authorizationStatus))
    @unknown default:
      break
    }
  }
  
  public func getLocation() {
    locationManager.requestLocation()
  }
  
  public func stop() {
    locationManager.stopUpdatingLocation()
  }
}

extension LocationManager {
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let loc = locations.first {
      location.send(loc)
    }
  }
  
  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus.send(.success(manager.authorizationStatus))
  }
  
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {

  }
}
