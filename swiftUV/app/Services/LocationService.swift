//
//  LocationService.swift
//  swiftUV
//
//  Created by Zlatan on 11/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import Foundation
import CoreLocation
import ZLogger
import Resolver

protocol LocationServiceDelegate: class {
  func didUpdateLocation(_ location: Location)
  func didFailUpdateLocation()
  
  func didAcceptLocationService()
  func didRefuseLocationService()
}

class LocationService: NSObject {
  
  private let locationManager: CLLocationManager
  weak var delegate: LocationServiceDelegate?

  private var authorizationStatus = CLAuthorizationStatus.notDetermined
  
  init(locationManager: CLLocationManager) {
    self.locationManager = locationManager
    super.init()
    self.requestAuthorization()
  }
  
  private func requestAuthorization() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    self.locationManager.requestWhenInUseAuthorization()
  }
  
  func searchLocation() {
    guard CLLocationManager.locationServicesEnabled() else {
      self.delegate?.didRefuseLocationService()
      return
    }
    
    guard self.authorizationStatus != .notDetermined else { return }
    
    guard self.authorizationStatus == .authorizedAlways ||
            self.authorizationStatus == .authorizedWhenInUse else {
      self.delegate?.didRefuseLocationService()
      return
    }
    
    self.locationManager.requestLocation()
  }
  
}

extension LocationService: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.locationManager.stopUpdatingLocation()

    guard let latitude = manager.location?.coordinate.latitude,
      let longitude = manager.location?.coordinate.longitude else {
        return
    }
    
    let location = CLLocation(latitude: latitude, longitude: longitude)
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(location) { placemarks, error in
      guard error == nil else {
        self.delegate?.didFailUpdateLocation()
        return
      }
      
      let customLocation = Location(latitude: latitude, longitude: longitude, city: placemarks?.first?.locality ?? "app.label.unknown")
      self.delegate?.didUpdateLocation(customLocation)
    }
    
    ZLogger.info(message: "location = \(location)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.delegate?.didFailUpdateLocation()
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    self.authorizationStatus = manager.authorizationStatus

    switch manager.authorizationStatus {
      case .authorizedAlways, .authorizedWhenInUse:
        self.delegate?.didAcceptLocationService()
      case .denied, .restricted:
        self.delegate?.didRefuseLocationService()
      default: ()
    }
  }
  
}
