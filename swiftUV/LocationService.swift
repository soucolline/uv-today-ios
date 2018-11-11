//
//  LocationService.swift
//  swiftUV
//
//  Created by Zlatan on 11/11/2018.
//  Copyright © 2018 Thomas Guilleminot. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: class {
  func didUpdateLocation()
  func didFailUpdateLocation()
  
  func didAcceptLocationService()
  func didRefuseLocationService()
}

class LocationService: NSObject {
  
  var locationManager: CLLocationManager
  weak var delegate: LocationServiceDelegate?
  
  init(with locationManager: CLLocationManager) {
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
    
    guard CLLocationManager.authorizationStatus() != .notDetermined else { return }
    
    guard CLLocationManager.authorizationStatus() == .authorizedAlways ||
          CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
      self.delegate?.didRefuseLocationService()
      return
    }
    
    self.locationManager.startMonitoringSignificantLocationChanges()
  }
  
}

extension LocationService: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.delegate?.didUpdateLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.delegate?.didFailUpdateLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      self.delegate?.didAcceptLocationService()
    case .denied, .restricted:
      self.delegate?.didRefuseLocationService()
    default: ()
    }
  }
  
}
